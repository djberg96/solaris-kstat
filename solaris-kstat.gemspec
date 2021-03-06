require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'solaris-kstat'
  spec.version    = '1.1.2'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Artistic 2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/solaris-kstat'
  spec.summary    = 'Interface for the Solaris kstat library'
  spec.test_files = Dir['test/*.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = Dir['certs/*']

  spec.add_dependency('ffi')

  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('mkmf-lite')
  spec.add_development_dependency('rake')

  spec.extra_rdoc_files = [
    'README',
    'CHANGES',
    'MANIFEST',
  ]

  spec.description = <<-EOF
    The solaris-kstat library provides a Ruby interface for gathering kernel
    statistics from the Solaris operating system. Each matching statistic is
    provided with its module, instance, and name fields, as well as its actual
    value.
  EOF
end
