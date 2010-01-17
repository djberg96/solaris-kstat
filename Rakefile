require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

desc "Clean the build files for the solaris-kstat source"
task :clean do
   FileUtils.rm_rf('solaris') if File.exists?('solaris')

   Dir.chdir('ext') do
      FileUtils.rm_rf('rkstat.c') if File.exists?('rkstat.c')
      FileUtils.rm_rf('rkstat.h') if File.exists?('rkstat.h')
      sh 'make distclean' if File.exists?('kstat.so')
      FileUtils.rm_rf('solaris/kstat.so') if File.exists?('solaris/kstat.so')
   end
end

desc "Build the solaris-kstat package (but don't install it)"
task :build => [:clean] do
   Dir.chdir('ext') do
      ruby 'extconf.rb'
      sh 'make'
      Dir.mkdir('solaris') unless File.exists?('solaris')
      FileUtils.cp('kstat.so', 'solaris')
   end
end

desc "Install the solaris-kstat package (non-gem)"
task :install => [:build] do
   Dir.chdir('ext') do
      sh 'make install'
   end
end

desc "Install the solaris-kstat package as a gem"
task :install_gem do
   ruby 'solaris-kstat.gemspec'
   file = Dir["*.gem"].first
   sh "gem install #{file}"
end

desc "Uninstall the solaris-kstat package. Use 'gem uninstall' for gem installs"
task :uninstall => [:clean] do
   file = File.join(CONFIG['sitearchdir'], 'solaris', 'kstat.so')
   FileUtils.rm_rf(file) if File.exists?(file)
end

desc "Run the example program"
task :example => [:build] do
   ruby "-Iext examples/example_kstat.rb"
end

Rake::TestTask.new do |t|
   task :test => :build
   t.libs << 'ext'
   t.verbose = true
   t.warning = true
end
