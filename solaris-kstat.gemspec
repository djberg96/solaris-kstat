require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'solaris-kstat'
  spec.version    = '1.0.2'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Artistic 2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://www.rubyforge.org/projects/solarisutils'
  spec.summary    = 'Interface for the Solaris kstat library'
  spec.test_file  = 'test/test_solaris_kstat.rb'
  spec.extensions = ['ext/extconf.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.rubyforge_project = 'solarisutils'

  spec.extra_rdoc_files = [
    'README',
    'CHANGES',
    'MANIFEST',
    'ext/solaris/rkstat.c'
  ]

  spec.description = <<-EOF
    The solaris-kstat library provides a Ruby interface for gathering kernel
    statistics from the Solaris operating system. Each matching statistic is
    provided with its module, instance, and name fields, as well as its actual
    value.
  EOF
end
