require 'ffi'

module Solaris
  class Kstat
    extend FFI::Library
    ffi_lib :kstat

    class KstatCtl < FFI::Struct
      layout(
        :kc_chain_id, :int,
        :kc_chain, :pointer,
        :kc_kd, :int
      )
    end

    class KstatStruct < FFI::Struct
      layout(
        :ks_crtime, :long_long,
        :ks_next, :pointer,
        :ks_kid, :int,
        :ks_module, [:char, 31],
        :ks_resv, :uchar,
        :ks_instance, :int,
        :ks_name, [:char, 31],
        :ks_type, :uchar,
        :ks_class, [:char, 31],
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

    attach_function :kstat_chain_update, [:pointer], :int
    attach_function :kstat_close, [:pointer], :int
    attach_function :kstat_lookup, [:pointer, :string, :int, :string], :pointer
    attach_function :kstat_open, [], :pointer
    attach_function :kstat_read, [KstatCtl, KstatStruct, :pointer], :int

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

      ptr = kstat_lookup(kptr, @module, @instance, @name)

      if ptr.null?
        raise SystemCallError.new('kstat_lookup', FFI.errno)
      end

      kstat = KstatStruct.new(ptr)

      begin

        # Sync the chain with the kernel
        if kstat_chain_update(kptr) < 0
          raise SystemCallError.new('kstat_chain_update', FFI.errno)
        end

        while !kstat.null?
          if @module && @module != kstat[:ks_module].to_s
            kstat = KstatStruct.new(kstat[:ks_next])
            next
          end

          if @instance != -1 && @instance != kstat[:ks_instance]
            kstat = KstatStruct.new(kstat[:ks_next])
            next
          end

          if @name && @name != kstat[:ks_name].to_s
            kstat = KstatStruct.new(kstat[:ks_next])
            next
          end

          #case kstat[:ks_type]
          #  when KS_TYPE_NAMED
          #  when KS_TYPE_IO
          #  when KS_TYPE_TIMER
          #  when KS_TYPE_INTR
          #  when KS_TYPE_RAW
          #end

          kstat = KstatStruct.new(kstat[:ks_next])
        end
      ensure
        kstat_close(kptr)
      end
    end
  end
end

Solaris::Kstat.new('cpu_info', 0).record
