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
  end
end
