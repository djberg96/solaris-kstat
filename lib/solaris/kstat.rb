require_relative 'kstat/structs'
require_relative 'kstat/functions'

module Solaris
  class Kstat
    extend FFI::Library
    include Solaris::Structs
    include Solaris::Functions

    # The version of the solaris-kstat library
    VERSION = '1.1.1'

    # The kstat module
    attr_accessor :module

    # The kstat instance number
    attr_accessor :instance

    # The kstat name
    attr_accessor :name

    # Creates and returns a Kstat object. This does NOT traverse the kstat
    # chain. The Kstat#record method uses the values passed to actually
    # retrieve data.
    #
    # You may specify a module, an instance and a name.  The module defaults to
    # nil (all modules), the instance defaults to -1 (all instances) and the
    # name defaults to nil (all names).
    #
    # Examples:
    #
    #   require 'solaris/kstat'
    #   include Kstat
    #
    #   k1 = Kstat.new                    # Everything
    #   k2 = Kstat.new('cpu')             # Just CPU info
    #   k3 = Kstat.new('cpu', 0)          # Just CPU info for instance 0
    #   k4 = Kstat.new('cpu', 0, 'sys')   # CPU info for instance 0 named 'sys'
    #
    def initialize(mod=nil, instance=-1, name=nil)
      # Type checking added since invalid values could cause a segfault later on.
      raise TypeError unless mod.is_a?(String) if mod
      raise TypeError unless instance.is_a?(Fixnum)
      raise TypeError unless name.is_a?(String) if name

      @module   = mod
      @instance = instance
      @name     = name
    end

    # Returns a nested hash based on the values passed to the constructor.  How
    # deeply that hash is nested depends on the values passed to the constructor.
    # The more specific your criterion, the less data you will receive.
    #
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
              shash = map_timer_data_type(kstat)
            else
              raise ArgumentError, 'unknown data record type'
          end

          # The various calls to .to_s here and elsewhere are necessary
          # to convert FFI's CharArray to Ruby strings.

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
        kstat_close(kptr)
      end

      mhash
    end # record

    private

    def map_timer_data_type(kstat)
      hash = {}

      ktimer = KstatTimer.new(kstat[:ks_data])

      ktime.members.each{ |m|
        if m == :name
          hash['name'] = ktimer[:name].to_s
        else
          hash[m.to_s] = ktimer[m]
        end
      }

      hash
    end

    def map_io_data_type(kstat)
      hash = {}

      kio = KstatIo.new(kstat[:ks_data])
      kio.members.each{ |m| hash[m.to_s] = kio[m] }

      hash
    end

    def map_intr_data_type(kstat)
      hash  = {}
      names = %w[hard soft watchdog spurious multiple_service]

      0.upto(4){ |i|
        ksi = KstatIntr.new(kstat[:ks_data] + (i * KstatIntr.size))
        hash[names[i]] = ksi[:intrs][i]
      }

      hash
    end

    def map_raw_data_type(kstat)
      hash = {}

      if kstat[:ks_module].to_s == 'unix'
        case kstat[:ks_name].to_s
          when 'vminfo'
            hash = map_raw_vminfo(kstat)
          when 'flushmeter'
            hash = map_raw_flushmeter(kstat)
          when 'ncstats'
            hash = map_raw_ncstats(kstat)
          when 'sysinfo'
            hash = map_raw_sysinfo(kstat)
          when 'var'
            hash = map_raw_var(kstat)
        end
      end

      if kstat[:ks_module].to_s == 'cpu_stat'
        hash = map_raw_cpu_sysinfo(kstat)
      end

      if kstat[:ks_module].to_s == 'nfs'
        if kstat[:ks_name].to_s == 'mntinfo'
          hash = map_raw_mnt_info(kstat)
        end
      end

      hash
    end

    def map_raw_mnt_info(kstat)
      hash = {}

      mntinfo = Mntinfo.new(kstat[:ks_data])

      mntinfo.members.each{ |m|
        next if m == :mik_timers # TODO: Add this information
        if [:mik_proto, :mik_curserver].include?(m)
          hash[m.to_s] = mntinfo[m].to_s
        else
          hash[m.to_s] = mntinfo[m]
        end
      }

      hash
    end

    def map_raw_cpu_sysinfo(kstat)
      hash = {}

      info = CpuSysinfo.new(kstat[:ks_data])

      info.members.each{ |m|
        if m == :cpu
          hash['cpu_idle']   = info[:cpu][0]
          hash['cpu_user']   = info[:cpu][1]
          hash['cpu_kernel'] = info[:cpu][2]
          hash['cpu_wait']   = info[:cpu][3]
        elsif m == :wait
          hash['wait_io']   = info[:wait][0]
          hash['wait_swap'] = info[:wait][1]
          hash['wait_pio']  = info[:wait][2]
        else
          hash[m.to_s] = info[m]
        end
      }

      hash
    end

    def map_raw_vminfo(kstat)
      hash = {}

      vmi = Vminfo.new(kstat[:ks_data])
      vmi.members.each{ |m| hash[m.to_s] = vmi[m] }

      hash
    end

    def map_raw_flushmeter(kstat)
      hash = {}

      fm = Flushmeter.new(kstat[:ks_data])
      fm.members.each{ |m| hash[m.to_s] = fm[m] }

      hash
    end

    def map_raw_ncstats(kstat)
      hash = {}

      ncs = NcStats.new(kstat[:ks_data])
      ncs.members.each{ |m| hash[m.to_s] = ncs[m] }

      hash
    end

    def map_raw_sysinfo(kstat)
      hash = {}

      sys = Sysinfo.new(kstat[:ks_data])
      sys.members.each{ |m| hash[m.to_s] = sys[m] }

      hash
    end

    def map_raw_var(kstat)
      hash = {}

      var = Var.new(kstat[:ks_data])
      var.members.each{ |m| hash[m.to_s] = var[m] }

      hash
    end

    def map_named_data_type(kstat)
      num = kstat[:ks_ndata]
      hash = {}

      0.upto(num-1){ |i|
        knp = KstatNamed.new(kstat[:ks_data] + (i * KstatNamed.size))
        name = knp[:name].to_s

        case knp[:data_type]
          when 0 # KSTAT_DATA_CHAR
            hash[name] = knp[:value][:c].to_s
          when 1 # KSTAT_DATA_INT32
            hash[name] = knp[:value][:i32]
          when 2 # KSTAT_DATA_UINT32
            hash[name] = knp[:value][:ui32]
          when 3 # KSTAT_DATA_INT64
            hash[name] = knp[:value][:i64]
          when 4 # KSTAT_DATA_UINT64
            hash[name] = knp[:value][:ui64]
          else
            hash[name] = "unknown"
        end
      }

      hash
    end
  end # Kstat
end # Solaris
