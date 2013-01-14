require File.join(File.dirname(__FILE__), 'kstat', 'structs')
require File.join(File.dirname(__FILE__), 'kstat', 'functions')

module Solaris
  class Kstat
    extend FFI::Library
    include Solaris::Structs
    include Solaris::Functions

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

          if kstat_read(kptr, kstat, nil) < 0
            raise SystemCallError.new('kstat_read', FFI.errno)
          end

          case kstat[:ks_type]
            when 0 # KSTAT_TYPE_RAW
              #map_raw_data_type
              puts "raw"
            when 1 # KS_TYPE_NAMED
              map_named_data_type(kstat)
            when 2 # KS_TYPE_INTR
              #map_intr_data_type
              puts "intr"
            when 3 # KS_TYPE_IO
              #map_io_data_type
              puts "io"
            when 4 # KS_TYPE_TIMER
              #map_timer_data_type
              puts "timer"
            else
              raise ArgumentError, 'unknown data record type'
          end

          kstat = KstatStruct.new(kstat[:ks_next])
        end
      ensure
        kstat_close(kptr)
      end
    end # record

    def map_named_data_type(kstat)
      knp = KstatNamed.new(kstat[:ks_data])

      0.upto(kstat[:ks_ndata]){ |i|
        case knp[:data_type]
          when 0 # KSTAT_DATA_CHAR
            p knp[:name]
          when 1 # KSTAT_DATA_INT32
          when 2 # KSTAT_DATA_UINT32
          when 3 # KSTAT_DATA_INT64
          when 4 # KSTAT_DATA_UINT64
          else
            "unknown"
        end
      }
    end
  end # Kstat
end # Solaris

Solaris::Kstat.new('cpu_info', 0).record
