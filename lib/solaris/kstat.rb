require File.join(File.dirname(__FILE__), 'kstat', 'structs')
require File.join(File.dirname(__FILE__), 'kstat', 'functions')

module Solaris
  class Kstat
    extend FFI::Library
    include Solaris::Structs
    include Solaris::Functions

    # The version of the solaris-kstat library
    VERSION = '1.1.0'

    attr_accessor :module
    attr_accessor :instance
    attr_accessor :name

    def initialize(mod=nil, instance=-1, name=nil)
      # Type checking added since invalid values could cause a segfault later on.
      raise TypeError unless mod.is_a?(String) if mod
      raise TypeError unless instance.is_a?(Fixnum)
      raise TypeError unless name.is_a?(String) if name

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
        kstat_close(kptr)
        raise SystemCallError.new('kstat_lookup', FFI.errno)
      end

      mhash = {} # Holds modules
      ihash = {} # Holds instances
      nhash = {} # Holds names
      shash = {} # Subhash for names

      # Sync the chain with the kernel
      if kstat_chain_update(kptr) < 0
        raise SystemCallError.new('kstat_chain_update', FFI.errno)
      end

      begin
        while !kstat.null?
          break if kstat[:ks_next].null?

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
              shash = map_raw_data_type(kstat)
            when 1 # KS_TYPE_NAMED
              shash = map_named_data_type(kstat)
            when 2 # KS_TYPE_INTR
              shash = map_intr_data_type(kstat)
            when 3 # KS_TYPE_IO
              shash = map_io_data_type(kstat)
            when 4 # KS_TYPE_TIMER
              shash = map_timer_data_type
            else
              raise ArgumentError, 'unknown data record type'
          end

          shash['class'] = kstat[:ks_class].to_s

          ks_name = kstat[:ks_name].to_s
          ks_instance = kstat[:ks_instance]
          ks_module = kstat[:ks_module].to_s

          nhash[ks_name]     = shash
          ihash[ks_instance] = nhash
          mhash[ks_module]   = ihash

          kstat = KstatStruct.new(kstat[:ks_next])
        end
      ensure
        #kstat_close(kptr)
      end

      # Note: We've got a custom destructor for the KstatCtl struct, so
      # that's why there's no explicit kstat_close here. This was done
      # because calling kstat_close any earlier resulted in the mhash
      # getting corrupted.
      #
      # See the functions.rb file for the implementation.

      mhash
    end # record

    private

    def map_timer_data_type(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        ktimer = KstatTimer.new(kstat[:ks_data] + (i * KstatTimer.size))
        hash['name']         = ktimer[:name].to_s
        hash['resv']         = ktimer[:resv]
        hash['num_events']   = ktimer[:num_events]
        hash['elapsed_time'] = ktimer[:elapsed_time]
        hash['min_time']     = ktimer[:min_time]
        hash['max_time']     = ktimer[:max_time]
        hash['start_time']   = ktimer[:start_time]
        hash['stop_time']    = ktimer[:stop_time]
      }

      hash
    end

    def map_io_data_type(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        kio = KstatIo.new(kstat[:ks_data] + (i * KstatIo.size))
        hash['nread']       = kio[:nread]
        hash['nwritten']    = kio[:nwritten]
        hash['reads']       = kio[:reads]
        hash['writes']      = kio[:writes]
        hash['wtime']       = kio[:wtime]
        hash['wlentime']    = kio[:wlentime]
        hash['wlastupdate'] = kio[:wlastupdate]
        hash['rtime']       = kio[:rtime]
        hash['rlentime']    = kio[:rlentime]
        hash['rlastupdate'] = kio[:rlastupdate]
      }

      hash
    end

    def map_intr_data_type(kstat)
      hash  = {}
      names = %w[hard soft watchdog spurious multiple_service]

      0.upto(4){ |i|
        ksi = KstatIntr.new(kstat[:ks_data] + (i * KstatIntr.size))
        hash[names[i]] = ksi[:intrs][i]
      }
    end

    def map_raw_data_type(kstat)
      if kstat[:ks_module] == 'unix'
        case kstat[:ks_name].to_s
          when 'vminfo'
            map_raw_vm_info(kstat)
          when 'flushmeter'
            map_raw_flushmeter(kstat)
          when 'ncstats'
            map_raw_ncstats(kstat)
          when 'sysinfo'
            map_raw_sysinfo(kstat)
          when 'var'
            map_raw_var(kstat)
        end
      end
    end

    def map_raw_vm_info(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        vmi = Vminfo.new(kstat[:ks_data] + (i * Vminfo.size))
        hash['freemem']    = vmi[:freemem]
        hash['swap_resv']  = vmi[:swap_resv]
        hash['swap_alloc'] = vmi[:swap_alloc]
        hash['swap_avail'] = vmi[:swap_avail]
        hash['swap_free']  = vmi[:swap_free]
        hash['updates']    = vmi[:updates]
      }

      hash
    end

    def map_raw_flushmeter(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        fm = Flushmeter.new(kstat[:ks_data] + (i * Flushmeter.size))
        hash['f_ctx']     = fm[:f_ctx]
        hash['f_segment'] = fm[:f_segment]
        hash['f_page']    = fm[:f_page]
        hash['f_partial'] = fm[:f_partial]
        hash['f_usr']     = fm[:f_usr]
        hash['f_region']  = fm[:f_region]
      }

      hash
    end

    def map_raw_ncstats(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        ncs = NcStats.new(kstat[:ks_data] + (i * NcStats.size))
        hash['hits']          = ncs[:hits]
        hash['misses']        = ncs[:misses]
        hash['enters']        = ncs[:enters]
        hash['dbl_enters']    = ncs[:dbl_enters]
        hash['long_enter']    = ncs[:long_enter]
        hash['long_look']     = ncs[:long_look]
        hash['move_to_front'] = ncs[:move_to_front]
        hash['purges']        = ncs[:purges]
      }

      hash
    end

    def map_raw_sysinfo(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        sys = Sysinfo.new(kstat[:ks_data] + (i * Sysinfo.size))
        hash['updates'] = sys[:updates]
        hash['runque']  = sys[:runque]
        hash['runocc']  = sys[:runocc]
        hash['swpque']  = sys[:swpque]
        hash['swpocc']  = sys[:swpocc]
        hash['waiting'] = sys[:waiting]
      }

      hash
    end

    def map_raw_var(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        var = Var.new(kstat[:ks_data] + (i * Var.size))
        hash['v_buf']       = var[:v_buf]
        hash['v_call']      = var[:v_call]
        hash['v_proc']      = var[:v_proc]
        hash['v_maxupttl']  = var[:v_maxupttl]
        hash['v_nglobpris'] = var[:v_nglobpris]
        hash['v_maxsyspri'] = var[:v_maxsyspri]
        hash['v_clist']     = var[:v_clist]
        hash['v_maxup']     = var[:v_maxup]
        hash['v_hbuf']      = var[:v_hbuf]
        hash['v_hmask']     = var[:v_hmask]
        hash['v_pbuf']      = var[:v_pbuf]
        hash['v_sptmap']    = var[:v_sptmap]
        hash['v_maxpmem']   = var[:v_maxpmem]
        hash['v_autoup']    = var[:v_autoup]
        hash['v_bufhwm']    = var[:v_bufhwm]
      }

      hash
    end

    def map_named_data_type(kstat)
      num  = kstat[:ks_ndata]
      hash = {}

      0.upto(num){ |i|
        knp = KstatNamed.new(kstat[:ks_data] + (i * KstatNamed.size))
        name = knp[:name].to_s

        case knp[:data_type]
          when 0 # KSTAT_DATA_CHAR
            hash[name] = knp[:value][:c]
          when 1 # KSTAT_DATA_INT32
            hash[name] = knp[:value][:i32]
          when 2 # KSTAT_DATA_UINT32
            hash[name] = knp[:value][:ui32]
          when 3 # KSTAT_DATA_INT64
            hash[name] = knp[:value][:i64]
          when 4 # KSTAT_DATA_UINT64
            hash[name] = knp[:value][:ui64]
          else
            "unknown"
        end
      }

      hash
    end
  end # Kstat
end # Solaris

if $0 == __FILE__
  require 'pp'
  #pp Solaris::Kstat.new('cpu_info').record['cpu_info']
  #k = Solaris::Kstat.new('cpu', 0, 'sys')
  k = Solaris::Kstat.new('cpu', 0)
  record = k.record
  p record['cpu'][0]
end
