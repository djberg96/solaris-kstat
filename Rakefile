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
    require 'rubygems/package'
    spec = eval(IO.read('solaris-kstat.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec, true)
  end

  desc "Install the solaris-kstat gem"
  task :install => [:create] do
    ruby 'solaris-kstat.gemspec'
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

desc "Run the example program"
task :example do
  ruby "-Ilib examples/example_kstat.rb"
end

namespace :test do
  desc "Run base tests"
  Rake::TestTask.new(:base) do |t|
    t.test_files = FileList['test/test_solaris_kstat.rb']
    t.verbose = true
    t.warning = true
  end

  desc "Run FFI struct tests"
  Rake::TestTask.new(:structs) do |t|
    t.test_files = FileList['test/test_solaris_kstat_structs.rb']
    t.verbose = true
    t.warning = true
  end

  desc "Run all tests"
  Rake::TestTask.new(:all) do |t|
    t.verbose = true
    t.warning = true
  end
end

task :default => "test:all"
