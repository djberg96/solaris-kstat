require File.join(File.dirname(__FILE__), 'structs')

module Solaris
  module Functions
    extend FFI::Library
    ffi_lib :kstat

    include Solaris::Structs

    attach_function :kstat_chain_update, [KstatCtl], :int
    attach_function :kstat_close, [KstatCtl], :int
    attach_function :kstat_lookup, [KstatCtl, :string, :int, :string], KstatStruct.by_ref
    attach_function :kstat_open, [], KstatCtl.by_ref
    attach_function :kstat_read, [KstatCtl, KstatStruct, :pointer], :int
  end
end
