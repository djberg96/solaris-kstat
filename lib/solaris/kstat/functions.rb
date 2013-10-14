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

    private :kstat_chain_update
    private :kstat_close
    private :kstat_lookup
    private :kstat_open
    private :kstat_read
  end
end
