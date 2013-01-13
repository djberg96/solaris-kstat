require 'ffi'

module Solaris
  class Kstat
    extend FFI::Library
    ffi_lib 'kstat'

    KSTAT_STRLEN = 31

    class KstatCtl < FFI::Struct
      layout(
        :kc_chain_id, :int,
        :kc_chain, :pointer,
        :kc_kd, :int
      )
    end

    # Size should be 152
    class Kstat < FFI::Struct
      layout(
        :ks_crtime, :long_long,
        :ks_next, :pointer,
        :ks_kid, :int,
        :ks_module, [:char, KSTAT_STRLEN],
        :ks_resv, :uchar,
        :ks_instance, :int,
        :ks_name, [:char, KSTAT_STRLEN],
        :ks_type, :uchar,
        :ks_class, [:char, KSTAT_STRLEN],
        :ks_flags, :uchar,
        :ks_data, :pointer,
        :ks_ndata, :uint,
        :ks_data_size, :ulong,
        :ks_snaptime, :long_long,
        :ks_update, :int,
        :ks_private, :pointer,
        :ks_snapshot, :int,
        :ks_lock, :pointer,
      )
    end

    attach_function :kstat_open, [], :pointer
    attach_function :kstat_close, [:pointer], :int
    attach_function :kstat_lookup, [:pointer, :string, :int, :string], :pointer
    attach_function :kstat_chain_update, [:pointer], :int

    attr_reader :module
    attr_reader :instance
    attr_reader :name

    def initialize(mod=nil, instance=-1, name=nil)
      @module   = mod
      @instance = instance
      @name     = name
    end

    def record
      kptr = kstat_open()

      if kptr.null?
        raise SystemCallError.new('kstat_open', FFI.errno)
      end

      kstat = kstat_lookup(kptr, @module, @instance, @name)

      if kstat.null?
        raise SystemCallError.new('kstat_lookup', FFI.errno)
      end

      # Sync the chain with the kernel
      if kstat_chain_update(kptr) < 0
        raise SystemCallError.new('kstat_chain_update', FFI.errno)
      end

      begin
      ensure
        kstat_close(kptr)
      end
    end
  end
end

Solaris::Kstat.new('cpu_info', 0).record
