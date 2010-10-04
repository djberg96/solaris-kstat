require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

desc "Clean the build files for the solaris-kstat source"
task :clean do
  rm_rf('solaris') if File.exists?('solaris')

  Dir['*.gem'].each{ |f| File.delete(f) }

  Dir.chdir('ext') do
    rm_rf('rkstat.c') if File.exists?('rkstat.c')
    rm_rf('rkstat.h') if File.exists?('rkstat.h')
    sh 'make distclean' if File.exists?('kstat.so')
    rm_rf('solaris/kstat.so') if File.exists?('solaris/kstat.so')
  end
end

desc "Build the solaris-kstat source"
task :build do
  Dir.chdir('ext') do
    ruby 'extconf.rb'
    sh 'make'
    cp 'kstat.so', 'solaris'
  end
end

namespace :gem do
  desc "Create the solaris-kstat gem"
  task :create => [:clean] do
    spec = eval(IO.read('solaris-kstat.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the solaris-kstat gem"
  task :install => [:build] do
    ruby 'solaris-kstat.gemspec'
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

desc "Run the example program"
task :example => [:build] do
  ruby "-Iext examples/example_kstat.rb"
end

Rake::TestTask.new do |t|
  task :test => [:build]
  t.libs << 'ext'
  t.verbose = true
  t.warning = true
end

task :default => :test
