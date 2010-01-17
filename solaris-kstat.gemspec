require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name       = 'solaris-kstat'
   gem.version    = '1.0.1'
   gem.author     = 'Daniel J. Berger'
   gem.license    = 'Artistic 2.0'
   gem.email      = 'djberg96@gmail.com'
   gem.homepage   = 'http://www.rubyforge.org/projects/solarisutils'
   gem.platform   = Gem::Platform::RUBY
   gem.summary    = 'Interface for the Solaris kstat library'
   gem.has_rdoc   = true
   gem.test_file  = 'test/test_solaris_kstat.rb'
   gem.extensions = ['ext/extconf.rb']
   gem.files      = Dir['**/*'].reject{ |f| f.include?('CVS') }

   gem.rubyforge_project = 'solarisutils'

   gem.extra_rdoc_files = [
      'README',
      'CHANGES',
      'MANIFEST',
      'ext/solaris/rkstat.c'
   ]

   gem.required_ruby_version = '>= 1.8.0'

   gem.description = <<-EOF
      The solaris-kstat library provides a Ruby interface for gathering kernel
      statistics from the operating system. Each matching statistic is provided
      with its module, instance, and name fields, as well as its actual value.
   EOF
end

Gem::Builder.new(spec).build
