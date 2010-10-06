#ifdef __cplusplus
extern "C" {
#endif

#define SOLARIS_KSTAT_VERSION "1.0.2"

// Function prototypes
static VALUE map_named_data_type(kstat_t* ksp);
static VALUE map_io_data_type(kstat_io_t* kio);
static VALUE map_intr_data_type(kstat_t* ksp);
static VALUE map_timer_data_type(kstat_timer_t* kt);
static VALUE map_raw_data_type(kstat_t* ksp);
static VALUE map_raw_vminfo(kstat_t* ksp);
static VALUE map_raw_flushmeter(kstat_t* ksp);
static VALUE map_raw_var(kstat_t* ksp);
static VALUE map_raw_ncstats(kstat_t* ksp);
static VALUE map_raw_sysinfo(kstat_t* ksp);
static VALUE map_raw_cpu_sysinfo(kstat_t* ksp);
static VALUE map_raw_mntinfo(kstat_t* ksp);

// Structure wrapped as our Kstat class
struct kstruct{
   kstat_ctl_t* kc;
   kstat_t* ksp;
};

typedef struct kstruct KstatStruct;

static void ks_free(KstatStruct* p){
  if(p->kc)
    kstat_close(p->kc);

  free(p);
}

// Helps reduce GC for String key/value pairs in a hash
void hash_add_pair(VALUE v_hash, const char *key, const char *value)
{
  volatile VALUE key_obj = rb_str_new2(key);
  rb_hash_aset(v_hash, key_obj, rb_str_new2(value));
}

// Helper functions

static VALUE map_raw_mntinfo(kstat_t* ksp){
  struct mntinfo_kstat *mptr; 
  mptr = (struct mntinfo_kstat*)(ksp->ks_data);
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("mik_proto"),rb_str_new2(mptr->mik_proto));
  rb_hash_aset(v_hash,rb_str_new2("mik_vers"),UINT2NUM(mptr->mik_vers));
  rb_hash_aset(v_hash,rb_str_new2("mik_flags"),UINT2NUM(mptr->mik_flags));
  rb_hash_aset(v_hash,rb_str_new2("mik_secmod"),UINT2NUM(mptr->mik_secmod));
  rb_hash_aset(v_hash,rb_str_new2("mik_curread"),UINT2NUM(mptr->mik_curread));
  rb_hash_aset(v_hash,rb_str_new2("mik_curwrite"), UINT2NUM(mptr->mik_curwrite));
  rb_hash_aset(v_hash,rb_str_new2("mik_timeo"),UINT2NUM(mptr->mik_timeo));
  rb_hash_aset(v_hash,rb_str_new2("mik_retrans"),UINT2NUM(mptr->mik_retrans));
  rb_hash_aset(v_hash,rb_str_new2("mik_acregmin"), UINT2NUM(mptr->mik_acregmin));
  rb_hash_aset(v_hash,rb_str_new2("mik_acregmax"), UINT2NUM(mptr->mik_acregmax));
  rb_hash_aset(v_hash,rb_str_new2("mik_acdirmin"), UINT2NUM(mptr->mik_acdirmin));
  rb_hash_aset(v_hash,rb_str_new2("mik_acdirmax"), UINT2NUM(mptr->mik_acdirmax));
  rb_hash_aset(v_hash,rb_str_new2("mik_noresponse"), UINT2NUM(mptr->mik_noresponse));
  rb_hash_aset(v_hash,rb_str_new2("mik_failover"), UINT2NUM(mptr->mik_failover));
  rb_hash_aset(v_hash,rb_str_new2("mik_remap"), UINT2NUM(mptr->mik_remap));
  rb_hash_aset(v_hash,rb_str_new2("mik_curserver"), rb_str_new2(mptr->mik_curserver));

  return v_hash;
}

static VALUE map_raw_vminfo(kstat_t* ksp){
  vminfo_t *vminfop;
  vminfop = (vminfo_t *)ksp->ks_data;
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("freemem"),ULL2NUM(vminfop->freemem));
  rb_hash_aset(v_hash,rb_str_new2("swap_resv"),ULL2NUM(vminfop->swap_resv));
  rb_hash_aset(v_hash,rb_str_new2("swap_alloc"),ULL2NUM(vminfop->swap_alloc));
  rb_hash_aset(v_hash,rb_str_new2("swap_avail"),ULL2NUM(vminfop->swap_avail));
  rb_hash_aset(v_hash,rb_str_new2("swap_free"),ULL2NUM(vminfop->swap_free));

  return v_hash;
}

static VALUE map_raw_var(kstat_t* ksp){
  struct var* v; 
  v = (struct var *)ksp->ks_data;
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("v_buf"),INT2NUM(v->v_buf));
  rb_hash_aset(v_hash,rb_str_new2("v_call"),INT2NUM(v->v_call));
  rb_hash_aset(v_hash,rb_str_new2("v_proc"),INT2NUM(v->v_proc));
  rb_hash_aset(v_hash,rb_str_new2("v_maxupttl"),INT2NUM(v->v_maxupttl));
  rb_hash_aset(v_hash,rb_str_new2("v_nglobpris"),INT2NUM(v->v_nglobpris));
  rb_hash_aset(v_hash,rb_str_new2("v_maxsyspri"),INT2NUM(v->v_maxsyspri));
  rb_hash_aset(v_hash,rb_str_new2("v_clist"),INT2NUM(v->v_clist));
  rb_hash_aset(v_hash,rb_str_new2("v_maxup"),INT2NUM(v->v_maxup));
  rb_hash_aset(v_hash,rb_str_new2("v_hbuf"),INT2NUM(v->v_hbuf));
  rb_hash_aset(v_hash,rb_str_new2("v_hmask"),INT2NUM(v->v_hmask));
  rb_hash_aset(v_hash,rb_str_new2("v_pbuf"),INT2NUM(v->v_pbuf));
  rb_hash_aset(v_hash,rb_str_new2("v_sptmap"),INT2NUM(v->v_sptmap));
  rb_hash_aset(v_hash,rb_str_new2("v_maxpmem"),INT2NUM(v->v_maxpmem));
  rb_hash_aset(v_hash,rb_str_new2("v_autoup"),INT2NUM(v->v_autoup));
  rb_hash_aset(v_hash,rb_str_new2("v_bufhwm"),INT2NUM(v->v_bufhwm));

  return v_hash;
}

static VALUE map_raw_flushmeter(kstat_t* ksp){
  struct flushmeter* fp;
  fp = (struct flushmeter *)ksp->ks_data;
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("f_ctx"),ULL2NUM(fp->f_ctx));
  rb_hash_aset(v_hash,rb_str_new2("f_segment"),ULL2NUM(fp->f_segment));
  rb_hash_aset(v_hash,rb_str_new2("f_page"),ULL2NUM(fp->f_page));
  rb_hash_aset(v_hash,rb_str_new2("f_partial"),ULL2NUM(fp->f_partial));
  rb_hash_aset(v_hash,rb_str_new2("f_usr"),ULL2NUM(fp->f_usr));
  rb_hash_aset(v_hash,rb_str_new2("f_region"),ULL2NUM(fp->f_region));

  return v_hash;
}

static VALUE map_raw_ncstats(kstat_t* ksp){
  struct ncstats* np;
  np = (struct ncstats *)ksp->ks_data;
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("hits"),INT2NUM(np->hits));
  rb_hash_aset(v_hash,rb_str_new2("misses"),INT2NUM(np->misses));
  rb_hash_aset(v_hash,rb_str_new2("enters"),INT2NUM(np->enters));
  rb_hash_aset(v_hash,rb_str_new2("dbl_enters"),INT2NUM(np->dbl_enters));
  rb_hash_aset(v_hash,rb_str_new2("long_enter"),INT2NUM(np->long_enter));
  rb_hash_aset(v_hash,rb_str_new2("long_look"),INT2NUM(np->long_look));
  rb_hash_aset(v_hash,rb_str_new2("move_to_front"),INT2NUM(np->move_to_front));
  rb_hash_aset(v_hash,rb_str_new2("purges"),INT2NUM(np->purges));

  return v_hash;
}

static VALUE map_raw_sysinfo(kstat_t* ksp){
  sysinfo_t* sp;
  sp = (sysinfo_t *)ksp->ks_data;
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("updates"),UINT2NUM(sp->updates));
  rb_hash_aset(v_hash,rb_str_new2("runque"),UINT2NUM(sp->runque));
  rb_hash_aset(v_hash,rb_str_new2("runocc"),UINT2NUM(sp->runocc));
  rb_hash_aset(v_hash,rb_str_new2("swpque"),UINT2NUM(sp->swpque));
  rb_hash_aset(v_hash,rb_str_new2("swpocc"),UINT2NUM(sp->swpocc));
  rb_hash_aset(v_hash,rb_str_new2("waiting"),UINT2NUM(sp->waiting));

  return v_hash;
}


// Maps the cpu_sysinfo struct from sys/sysinfo.h into a hash.
static VALUE map_raw_cpu_sysinfo(kstat_t* ksp){
  cpu_sysinfo_t* cptr;
  cptr = (cpu_sysinfo_t *)ksp->ks_data;
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("cpu_idle"),UINT2NUM(cptr->cpu[CPU_IDLE]));
  rb_hash_aset(v_hash,rb_str_new2("cpu_user"),UINT2NUM(cptr->cpu[CPU_USER]));
  rb_hash_aset(v_hash,rb_str_new2("cpu_kernel"),UINT2NUM(cptr->cpu[CPU_KERNEL]));
  rb_hash_aset(v_hash,rb_str_new2("cpu_wait"),UINT2NUM(cptr->cpu[CPU_WAIT]));
  rb_hash_aset(v_hash,rb_str_new2("wait_io"),UINT2NUM(cptr->wait[W_IO]));
  rb_hash_aset(v_hash,rb_str_new2("wait_swap"),UINT2NUM(cptr->wait[W_SWAP]));
  rb_hash_aset(v_hash,rb_str_new2("wait_pio"),UINT2NUM(cptr->wait[W_PIO]));
  rb_hash_aset(v_hash,rb_str_new2("bread"),UINT2NUM(cptr->bread));
  rb_hash_aset(v_hash,rb_str_new2("bwrite"),UINT2NUM(cptr->bwrite));
  rb_hash_aset(v_hash,rb_str_new2("lread"),UINT2NUM(cptr->lread));
  rb_hash_aset(v_hash,rb_str_new2("lwrite"),UINT2NUM(cptr->lwrite));
  rb_hash_aset(v_hash,rb_str_new2("phread"),UINT2NUM(cptr->phread));
  rb_hash_aset(v_hash,rb_str_new2("phwrite"),UINT2NUM(cptr->phwrite));
  rb_hash_aset(v_hash,rb_str_new2("pswitch"),UINT2NUM(cptr->pswitch));
  rb_hash_aset(v_hash,rb_str_new2("trap"),UINT2NUM(cptr->trap));
  rb_hash_aset(v_hash,rb_str_new2("intr"),UINT2NUM(cptr->intr));
  rb_hash_aset(v_hash,rb_str_new2("syscall"),UINT2NUM(cptr->syscall));
  rb_hash_aset(v_hash,rb_str_new2("sysread"),UINT2NUM(cptr->sysread));
  rb_hash_aset(v_hash,rb_str_new2("syswrite"),UINT2NUM(cptr->syswrite));
  rb_hash_aset(v_hash,rb_str_new2("sysfork"),UINT2NUM(cptr->sysfork));
  rb_hash_aset(v_hash,rb_str_new2("sysvfork"),UINT2NUM(cptr->sysvfork));
  rb_hash_aset(v_hash,rb_str_new2("sysexec"),UINT2NUM(cptr->sysexec));
  rb_hash_aset(v_hash,rb_str_new2("readch"),UINT2NUM(cptr->readch));
  rb_hash_aset(v_hash,rb_str_new2("writech"),UINT2NUM(cptr->writech));
  rb_hash_aset(v_hash,rb_str_new2("rcvint"),UINT2NUM(cptr->rcvint));
  rb_hash_aset(v_hash,rb_str_new2("xmtint"),UINT2NUM(cptr->xmtint));
  rb_hash_aset(v_hash,rb_str_new2("mdmint"),UINT2NUM(cptr->mdmint));
  rb_hash_aset(v_hash,rb_str_new2("rawch"),UINT2NUM(cptr->rawch));
  rb_hash_aset(v_hash,rb_str_new2("canch"),UINT2NUM(cptr->canch));
  rb_hash_aset(v_hash,rb_str_new2("outch"),UINT2NUM(cptr->outch));
  rb_hash_aset(v_hash,rb_str_new2("msg"),UINT2NUM(cptr->msg));
  rb_hash_aset(v_hash,rb_str_new2("sema"),UINT2NUM(cptr->sema));
  rb_hash_aset(v_hash,rb_str_new2("namei"),UINT2NUM(cptr->namei));
  rb_hash_aset(v_hash,rb_str_new2("ufsiget"),UINT2NUM(cptr->ufsiget));
  rb_hash_aset(v_hash,rb_str_new2("ufsdirblk"),UINT2NUM(cptr->ufsdirblk));
  rb_hash_aset(v_hash,rb_str_new2("ufsipage"),UINT2NUM(cptr->ufsipage));
  rb_hash_aset(v_hash,rb_str_new2("ufsinopage"),UINT2NUM(cptr->ufsinopage));
  rb_hash_aset(v_hash,rb_str_new2("inodeovf"),UINT2NUM(cptr->inodeovf));
  rb_hash_aset(v_hash,rb_str_new2("fileovf"),UINT2NUM(cptr->fileovf));
  rb_hash_aset(v_hash,rb_str_new2("procovf"),UINT2NUM(cptr->procovf));
  rb_hash_aset(v_hash,rb_str_new2("intrthread"),UINT2NUM(cptr->intrthread));
  rb_hash_aset(v_hash,rb_str_new2("intrblk"),UINT2NUM(cptr->intrblk));
  rb_hash_aset(v_hash,rb_str_new2("idlethread"),UINT2NUM(cptr->idlethread));
  rb_hash_aset(v_hash,rb_str_new2("inv_swtch"),UINT2NUM(cptr->inv_swtch));
  rb_hash_aset(v_hash,rb_str_new2("nthreads"),UINT2NUM(cptr->nthreads));
  rb_hash_aset(v_hash,rb_str_new2("cpumigrate"),UINT2NUM(cptr->cpumigrate));
  rb_hash_aset(v_hash,rb_str_new2("xcalls"),UINT2NUM(cptr->xcalls));
  rb_hash_aset(v_hash,rb_str_new2("mutex_adenters"), UINT2NUM(cptr->mutex_adenters));
  rb_hash_aset(v_hash,rb_str_new2("rw_rdfails"),UINT2NUM(cptr->rw_rdfails));
  rb_hash_aset(v_hash,rb_str_new2("rw_wrfails"),UINT2NUM(cptr->rw_wrfails));
  rb_hash_aset(v_hash,rb_str_new2("modload"),UINT2NUM(cptr->modload));
  rb_hash_aset(v_hash,rb_str_new2("modunload"),UINT2NUM(cptr->modunload));
  rb_hash_aset(v_hash,rb_str_new2("bawrite"),UINT2NUM(cptr->bawrite));

#ifdef STATISTICS
  rb_hash_aset(v_hash,rb_str_new2("rw_enters"),UINT2NUM(cptr->rw_enters));
  rb_hash_aset(v_hash,rb_str_new2("win_uo_cnt"),UINT2NUM(cptr->win_uo_cnt));
  rb_hash_aset(v_hash,rb_str_new2("win_uu_cnt"),UINT2NUM(cptr->win_uu_cnt));
  rb_hash_aset(v_hash,rb_str_new2("win_so_cnt"),UINT2NUM(cptr->win_so_cnt));
  rb_hash_aset(v_hash,rb_str_new2("win_su_cnt"),UINT2NUM(cptr->win_su_cnt));
  rb_hash_aset(v_hash,rb_str_new2("win_suo_cnt"),UINT2NUM(cptr->win_suo_cnt));
#endif

  return v_hash;
}

/* There are several different structs possible here.  We'll forward this
 * call to the appropriate mapper based on the module and name.
 *
 * A few names are not yet being handled.
 */
static VALUE map_raw_data_type(kstat_t* ksp){
  VALUE v_hash = rb_hash_new();

  if(!strcmp(ksp->ks_module, "unix")){
    if(!strcmp(ksp->ks_name, "vminfo")){
      v_hash = map_raw_vminfo(ksp);
    }
    else if(!strcmp(ksp->ks_name, "flushmeter")){
      v_hash = map_raw_flushmeter(ksp);
    }
    else if(!strcmp(ksp->ks_name, "ncstats")){
      v_hash = map_raw_ncstats(ksp);
    }
    else if(!strcmp(ksp->ks_name, "sysinfo")){
      v_hash = map_raw_sysinfo(ksp);
    }
    else if(!strcmp(ksp->ks_name, "var")){
       v_hash = map_raw_var(ksp);
    }
    else{
      // Return an empty hash for unhandled names for now
      v_hash = rb_hash_new();
    }
  }

  if(!strcmp(ksp->ks_module,"cpu_stat"))
    v_hash = map_raw_cpu_sysinfo(ksp);

  if(!strcmp(ksp->ks_module,"nfs")){
    if(!strcmp(ksp->ks_name,"mntinfo")){
      v_hash = map_raw_mntinfo(ksp);
    }
  }

  return v_hash;
}

static VALUE map_timer_data_type(kstat_timer_t* t){
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("name"),rb_str_new2(t->name));
  rb_hash_aset(v_hash,rb_str_new2("num_events"),ULL2NUM(t->num_events));
  rb_hash_aset(v_hash,rb_str_new2("elapsed_time"),ULL2NUM(t->elapsed_time));
  rb_hash_aset(v_hash,rb_str_new2("min_time"),ULL2NUM(t->min_time));
  rb_hash_aset(v_hash,rb_str_new2("max_time"),ULL2NUM(t->max_time));
  rb_hash_aset(v_hash,rb_str_new2("start_time"),ULL2NUM(t->start_time));
  rb_hash_aset(v_hash,rb_str_new2("stop_time"),ULL2NUM(t->stop_time));

  return v_hash;
}

static VALUE map_intr_data_type(kstat_t* ksp){
  int i;
  kstat_intr_t* kp;
  kp = (kstat_intr_t *)ksp->ks_data;
  VALUE v_hash = rb_hash_new();
  static char* intr_names[] =
    {"hard", "soft", "watchdog", "spurious", "multiple_service"};

  for(i = 0; i < KSTAT_NUM_INTRS; i++)
    rb_hash_aset(v_hash,rb_str_new2(intr_names[i]),UINT2NUM(kp->intrs[i]));

  return v_hash;
}

static VALUE map_io_data_type(kstat_io_t* k){
  volatile VALUE v_hash = rb_hash_new();

  rb_hash_aset(v_hash,rb_str_new2("nread"),ULL2NUM(k->nread));
  rb_hash_aset(v_hash,rb_str_new2("nwritten"),ULL2NUM(k->nwritten));
  rb_hash_aset(v_hash,rb_str_new2("reads"),UINT2NUM(k->reads));
  rb_hash_aset(v_hash,rb_str_new2("writes"),UINT2NUM(k->writes));
  rb_hash_aset(v_hash,rb_str_new2("wtime"),ULL2NUM(k->wtime));
  rb_hash_aset(v_hash,rb_str_new2("wlentime"),ULL2NUM(k->wlentime));
  rb_hash_aset(v_hash,rb_str_new2("wlastupdate"),ULL2NUM(k->wlastupdate));
  rb_hash_aset(v_hash,rb_str_new2("rtime"),ULL2NUM(k->rtime));
  rb_hash_aset(v_hash,rb_str_new2("rlentime"),ULL2NUM(k->rlentime));
  rb_hash_aset(v_hash,rb_str_new2("rlastupdate"),ULL2NUM(k->rlastupdate));
  rb_hash_aset(v_hash,rb_str_new2("wcnt"),UINT2NUM(k->wcnt));
  rb_hash_aset(v_hash,rb_str_new2("rcnt"),UINT2NUM(k->rcnt));

  return v_hash;
}

static VALUE map_named_data_type(kstat_t* ksp){
  volatile VALUE v_hash;
  kstat_named_t* knp;
  knp = (kstat_named_t *)ksp->ks_data;
  int i;

  v_hash = rb_hash_new();

  for(i = 0; i < ksp->ks_ndata; i++, knp++){
    switch (knp->data_type){
      case KSTAT_DATA_CHAR:
        hash_add_pair(v_hash,knp->name,knp->value.c);
        break;
      case KSTAT_DATA_INT32:
        rb_hash_aset(v_hash,rb_str_new2(knp->name),INT2NUM(knp->value.i32));
        break;
      case KSTAT_DATA_UINT32:
        rb_hash_aset(v_hash,rb_str_new2(knp->name),UINT2NUM(knp->value.ui32));
        break;
      case KSTAT_DATA_INT64:
        rb_hash_aset(v_hash,rb_str_new2(knp->name),LL2NUM(knp->value.i64));
        break;
      case KSTAT_DATA_UINT64:
        rb_hash_aset(v_hash,rb_str_new2(knp->name),ULL2NUM(knp->value.ui64));
        break;
      default:
        hash_add_pair(v_hash,knp->name,"Unknown");
        break;
    }
  }

  return v_hash;
}

#ifdef __cplusplus
}
#endif
