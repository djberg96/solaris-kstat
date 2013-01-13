require 'ffi'

module Solaris
  class Kstat
    extend FFI::Library
    ffi_lib 'kstat'

    attach_function :kstat_open, [], :pointer
    attach_function :kstat_close, [:pointer], :int

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

      begin
      ensure
        kstat_close(kptr)
      end
    end
  end
end

Solaris::Kstat.new.record
