require File.join(File.dirname(__FILE__), 'structs')

module Solaris
  module Functions
    extend FFI::Library
    ffi_lib :kstat

    include Solaris::Structs

    class Solaris::Structs::KstatCtl < FFI::Struct
      def self.release(pointer)
        Solaris::Functions.kstat_close(pointer)
      end
    end

    attach_function :kstat_chain_update, [KstatCtl.by_ref], :int
    attach_function :kstat_close, [KstatCtl], :int
    attach_function :kstat_lookup, [KstatCtl.by_ref, :string, :int, :string], KstatStruct.by_ref
    attach_function :kstat_open, [], KstatCtl.auto_ptr
    attach_function :kstat_read, [KstatCtl.by_ref, KstatStruct.by_ref, :pointer], :int
  end
end
