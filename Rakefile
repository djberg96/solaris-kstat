require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'

CLEAN.include(
  '**/*.gem', # Gem files
  '**/*.rbc', # Rubinius
  '**/*.rbx'  # Rubinius
)

namespace :gem do
  desc "Create the solaris-kstat gem"
  task :create => [:clean] do
    spec = eval(IO.read('solaris-kstat.gemspec'))
    if Gem::VERSION < "2.0.0"
      Gem::Builder.new(spec).build
    else
      require 'rubygems/package'
      Gem::Package.build(spec)
    end
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
  t.verbose = true
  t.warning = true
end

task :default => :test
