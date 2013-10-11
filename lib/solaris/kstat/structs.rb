require 'ffi'

module Solaris
  module Structs
    extend FFI::Library

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

    class Addr < FFI::Union
      layout(
        :ptr, :char,
        :ptr32, :int32,
        :pad, [:char, 8]
      )
    end

    class Str < FFI::Struct
      layout(:union, Addr, :len, :uint32)
    end

    class Value < FFI::Union
      layout(
        :c, [:char, 16],
        :i32, :int32,
        :ui32, :uint32,
        :str, Str,
        :i64, :int64,
        :ui64, :uint64,
        :l, :long,
        :ul, :ulong,
        :ll, :long_long,
        :ull, :ulong_long,
        :f, :float,
        :d, :double
      )
    end

    class KstatNamed < FFI::Struct
      layout(
        :name, [:char, 31],
        :data_type, :uchar,
        :value, Value
      )
    end

    class Vminfo < FFI::Struct
      layout(
        :freemem, :uint64_t,
        :swap_resv, :uint64_t,
        :swap_alloc, :uint64_t,
        :swap_avail, :uint64_t,
        :swap_free, :uint64_t,
        :updates, :uint64_t
      )
    end

    class Flushmeter < FFI::Struct
      layout(
        :f_ctx, :uint,
        :f_segment, :uint,
        :f_page, :uint,
        :f_partial, :uint,
        :f_usr, :uint,
        :f_region, :uint
      )
    end

    class NcStats < FFI::Struct
      layout(
        :hits, :int,
        :misses, :int,
        :enters, :int,
        :dbl_enters, :int,
        :long_enter, :int,
        :long_look, :int,
        :move_to_front, :int,
        :purges, :int
      )
    end

    class Sysinfo < FFI::Struct
      layout(
        :updates, :uint,
        :runque, :uint,
        :runocc, :uint,
        :swpque, :uint,
        :swpocc, :uint,
        :waiting, :uint
      )
    end

    class Var < FFI::Struct
      layout(
        :v_buf,       :int,
        :v_call,      :int,
        :v_proc,      :int,
        :v_maxupttl,  :int,
        :v_nglobpris, :int,
        :v_maxsyspri, :int,
        :v_clist,     :int,
        :v_maxup,     :int,
        :v_hbuf,      :int,
        :v_hmask,     :int,
        :v_pbuf,      :int,
        :v_sptmap,    :int,
        :v_maxpmem,   :int,
        :v_autoup,    :int,
        :v_bufhwm,    :int
      )
    end

    class KstatIntr < FFI::Struct
      layout(:intrs, [:uint, 5])
    end

    class KstatIo < FFI::Struct
      layout(
        :nread, :ulong_long,
        :nwritten, :ulong_long,
        :reads, :uint,
        :writes, :uint,
        :wtime, :long_long,
        :wlentime, :long_long,
        :wlastupdate, :long_long,
        :rtime, :long_long,
        :rlentime, :long_long,
        :rlastupdate, :long_long,
        :wcnt, :uint,
        :rcnt, :uint
      )
    end

    class KstatTimer < FFI::Struct
      layout(
        :name, [:char, 31],
        :resv, :uchar,
        :num_events, :ulong_long,
        :elapsed_time, :long_long,
        :min_time, :long_long,
        :max_time, :long_long,
        :start_time, :long_long,
        :stop_time, :long_long
      )
    end

    class CpuSysinfo < FFI::Struct
      layout(
        :cpu, [:uint_t, 4],   # CPU_STATES = 4
        :wait, [:uint_t, 3],  # W_STATES = 3
        :bread, :uint_t,
        :bwrite, :uint_t,
        :lread, :uint_t,
        :lwrite, :uint_t,
        :phread, :uint_t,
        :phwrite, :uint_t,
        :pswitch, :uint_t,
        :trap, :uint_t,
        :intr, :uint_t,
        :syscall, :uint_t,
        :sysread, :uint_t,
        :syswrite, :uint_t,
        :sysfork, :uint_t,
        :sysvfork, :uint_t,
        :sysexec, :uint_t,
        :readch, :uint_t,
        :writech, :uint_t,
        :rcvint, :uint_t, # unused
        :xmtint, :uint_t, # unused
        :mdmint, :uint_t, # unused
        :rawch, :uint_t,
        :canch, :uint_t,
        :outch, :uint_t,
        :msg, :uint_t,
        :sema, :uint_t,
        :namei, :uint_t,
        :ufsiget, :uint_t,
        :ufsdirblk, :uint_t,
        :ufsipage, :uint_t,
        :ufsinopage, :uint_t,
        :inodeovf, :uint_t,
        :fileovf, :uint_t
        :procovf, :uint_t,
        :intrthread, :uint_t,
        :intrblk, :uint_t,
        :inv_swtch, :uint_t,
        :nthreads, :uint_t,
        :cpumigrate, :uint_t,
        :xcalls, :uint_t,
        :mutex_adenters, :uint_t,
        :rw_rdfails, :uint_t,
        :rw_wrfails, :uint_t,
        :modload, :uint_t,
        :modunload, :uint_t,
        :bawrite, :uint_t
        :rw_enters, :uint_t,
        :win_uo_cnt, :uint_t,
        :win_uu_cnt, :uint_t,
        :win_so_cnt, :uint_t,
        :win_su_cnt, :uint_t,
        :win_suo_cnt, :uint_t
      )
    end
  end
end
