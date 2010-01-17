require 'mkmf'
require 'fileutils'

dir_config('kstat')

# This package requires Solaris 2.8 or later
unless have_header('kstat.h')
   STDERR.puts "The kstat.h header file was not found. Exiting."
   exit
end

$INCFLAGS += " -Isolaris"

have_library('kstat')
create_makefile('solaris/kstat', 'solaris')
