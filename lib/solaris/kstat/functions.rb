require File.join(File.dirname(__FILE__), 'structs')

module Solaris
  module Functions
    extend FFI::Library
    ffi_lib :kstat

    include Solaris::Structs

    attach_function :kstat_chain_update, [:pointer], :int
    attach_function :kstat_close, [:pointer], :int
    attach_function :kstat_lookup, [:pointer, :string, :int, :string], :pointer
    attach_function :kstat_open, [], :pointer
    attach_function :kstat_read, [KstatCtl, KstatStruct, :pointer], :int
  end
end
