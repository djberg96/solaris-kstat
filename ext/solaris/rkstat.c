#ifdef __cplusplus
extern "C" {
#endif

#include <kstat.h>
#include <nfs/nfs.h>
#include <nfs/nfs_clnt.h>
#include <sys/utsname.h>
#include <sys/sysinfo.h>
#include <sys/inttypes.h>
#include <sys/dnlc.h>
#include <sys/vmmeter.h>
#include <sys/var.h>
#include <errno.h>
#include <string.h>

#include "ruby.h"
#include "rkstat.h"

VALUE cKstatError;

static VALUE ks_allocate(VALUE klass){
  KstatStruct* ptr;
  return Data_Make_Struct(klass, KstatStruct, 0, ks_free, ptr);
}

/*
 * call-seq:
 *    Kstat.new(module=nil, instance=-1, name=nil)
 *
 * Creates and returns a Kstat object. This does NOT traverse the kstat
 * chain. The Kstat#record method uses the values passed to actually
 * retrieve data.
 *
 * You may specify a module, an instance and a name.  The module defaults to
 * nil (all modules), the instance defaults to -1 (all instances) and the
 * name defaults to nil (all names).
 */
VALUE ks_init(int argc, VALUE* argv, VALUE self){
  KstatStruct* ptr;
  VALUE v_module, v_instance, v_name;

  Data_Get_Struct(self,KstatStruct,ptr);

  rb_scan_args(argc, argv, "03", &v_module, &v_instance, &v_name);

  if(!NIL_P(v_module)){
    SafeStringValue(v_module);
    rb_iv_set(self, "@module", v_module);
  }
  else{
    rb_iv_set(self, "@module", Qnil);
  }

  if(!NIL_P(v_name)){
    SafeStringValue(v_name);
    rb_iv_set(self, "@name", v_name);
  }
  else{
    rb_iv_set(self, "@name", Qnil);
  }

  if(!NIL_P(v_instance))
    rb_iv_set(self, "@instance", v_instance);
  else
    rb_iv_set(self, "@instance", Qnil);

  return self;
}

/*
 * Helper function ks_record which will either return an existing value for
 * the given key, or assign that key a new empty hash if it has no value
 * associated with it.
 */
VALUE get_hash_for_key(VALUE v_hash, VALUE v_key){
  volatile VALUE v_new_hash;

  v_new_hash = rb_hash_aref(v_hash, v_key);

  if(NIL_P(v_new_hash)){
    v_new_hash = rb_hash_new();
    rb_hash_aset(v_hash, v_key, v_new_hash);    
  }

  return v_new_hash;
}

/*
 * Returns a nested hash based on the values passed to the constructor.  How
 * deeply that hash is nested depends on the values passed to the constructor.
 * The more specific your criterion, the less data you will receive.
 */
VALUE ks_record(VALUE self){
  volatile VALUE v_m_hash, v_i_hash, v_n_hash, v_s_hash;
  KstatStruct* ptr;
  kstat_io_t kio;
  kstat_timer_t kt;
  char* module;
  char* name;
  int instance = -1; // -1 represents all instances (the default)

  VALUE v_module, v_instance, v_name;

  Data_Get_Struct(self,KstatStruct,ptr);

  v_m_hash = rb_hash_new(); // Module name is key, holds v_i_hashes

  v_module   = rb_iv_get(self, "@module");
  v_instance = rb_iv_get(self, "@instance");
  v_name     = rb_iv_get(self, "@name");

  // Module is NULL by default (i.e. all modules are returned)
  if(NIL_P(v_module))
    module = NULL;
  else
    module = StringValuePtr(v_module);

  // Instance defaults to -1 (i.e. all instances are returned)
  if(!NIL_P(v_instance))
    instance = NUM2INT(v_instance);

  // Name is NULL by default (i.e. all names are returned)
  if(NIL_P(v_name))
    name = NULL;
  else
    name = StringValuePtr(v_name);

  // A failure probably means the module, instance or name doesn't exist
  if((ptr->kc = kstat_open()) == NULL)
    rb_raise(cKstatError, "kstat_open() failure: %s", strerror(errno));

  /*
   * Traverse the kstat chain, looking for matches based on supplied data.
   * A failure likely means a non-existant module or name was provided.
   */
  if((ptr->ksp = kstat_lookup(ptr->kc, module, instance, name)) == NULL)
    rb_raise(cKstatError, "kstat_lookup() failure: %s", strerror(errno));

  // Sync the chain with the kernel
  if(kstat_chain_update(ptr->kc) == -1)
    rb_raise(cKstatError, "kstat_chain_update() failure: %s", strerror(errno));

  while(ptr->ksp){
    // If a module is specified, ignore modules that don't match
    if((module) && (strcmp(module,ptr->ksp->ks_module))){
      ptr->ksp = ptr->ksp->ks_next;
      continue;
    }

    // If an instance is specified, ignore instances that don't match
    if((instance != -1) && (instance != ptr->ksp->ks_instance)){
      ptr->ksp = ptr->ksp->ks_next;
      continue;
    }

    // If a name is specified, ignore names that don't match
    if((name) && (strcmp(name,ptr->ksp->ks_name))){
      ptr->ksp = ptr->ksp->ks_next;
      continue;
    }

    // Call the appropriate data mapper based on ks_type
    switch(ptr->ksp->ks_type){
      case KSTAT_TYPE_NAMED:
        kstat_read(ptr->kc, ptr->ksp, NULL);
        v_s_hash = map_named_data_type(ptr->ksp);
        break;
      case KSTAT_TYPE_IO:
        kstat_read(ptr->kc, ptr->ksp, &kio);
        v_s_hash = map_io_data_type(&kio);
        break;
      case KSTAT_TYPE_TIMER:
        kstat_read(ptr->kc, ptr->ksp, &kt);
        v_s_hash = map_timer_data_type(&kt);
      case KSTAT_TYPE_INTR:
        kstat_read(ptr->kc, ptr->ksp, NULL);
        v_s_hash = map_intr_data_type(ptr->ksp);
        break;
      case KSTAT_TYPE_RAW:
        kstat_read(ptr->kc, ptr->ksp, NULL);
        v_s_hash = map_raw_data_type(ptr->ksp);   
        break;
      default:
        rb_raise(cKstatError,"Unknown data record type");
    }

    /* Set the class for this set of statistics */
    if(ptr->ksp->ks_class)
      rb_hash_aset(v_s_hash, rb_str_new2("class"), rb_str_new2(ptr->ksp->ks_class));

    v_i_hash = get_hash_for_key(v_m_hash, rb_str_new2(ptr->ksp->ks_module));
    v_n_hash = get_hash_for_key(v_i_hash, INT2FIX(ptr->ksp->ks_instance));

    rb_hash_aset(v_n_hash, rb_str_new2(ptr->ksp->ks_name), v_s_hash);
    rb_hash_aset(v_i_hash, INT2FIX(ptr->ksp->ks_instance),  v_n_hash);
    rb_hash_aset(v_m_hash, rb_str_new2(ptr->ksp->ks_module), v_i_hash);

    ptr->ksp = ptr->ksp->ks_next;
  }

  return v_m_hash;
}

void Init_kstat(){
  VALUE mSolaris, cKstat;

  /* The Solaris module only serves as a toplevel namespace */
  mSolaris = rb_define_module("Solaris");

  /* The Kstat class encapsulates kstat (kernel statistics) information */
  cKstat = rb_define_class_under(mSolaris, "Kstat", rb_cObject);

  /* The Kstat::Error class is raised if any of the Kstat methods fail */
  cKstatError = rb_define_class_under(cKstat, "Error", rb_eStandardError);

  rb_define_alloc_func(cKstat, ks_allocate);

  // Instance Methods

  rb_define_method(cKstat, "initialize", ks_init, -1);
  rb_define_method(cKstat, "record", ks_record, 0);

  // Kernel module
  rb_define_attr(cKstat, "module", 1, 1);

  // Index of module entity
  rb_define_attr(cKstat, "instance", 1, 1);

  // Unique name within module
  rb_define_attr(cKstat, "name", 1, 1);

  /* 1.0.2: The version of the solaris-kstat library */
  rb_define_const(cKstat, "VERSION", rb_str_new2(SOLARIS_KSTAT_VERSION));
}

#ifdef __cplusplus
}
#endif
