require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

CLEAN.include(
  '**/*.gem',               # Gem files
  '**/*.rbc',               # Rubinius
  '**/*.o',                 # C object file
  '**/*.log',               # Ruby extension build log
  '**/Makefile',            # C Makefile
  '**/conftest.dSYM',       # OS X build directory
  "**/*.#{CONFIG['DLEXT']}" # C shared object
)

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
