#######################################################################
# example_kstat.rb
#
# Sample script for general futzing. You can run this script via
# the 'rake example' task.
#######################################################################
require "solaris/kstat"
require "pp"
include Solaris

puts "VERSION: " + Kstat::VERSION
puts

k1 = Kstat.new('cpu_info', 0)
pp k1.record

puts '=' * 40

k2 = Kstat.new('unix', 0, 'biostats')
pp k2

# Print all modules
k = Kstat.new
k.record.each{ |k,v|
   p k
}

=begin
pp k.record["cpu_info"][0]["cpu_info0"]
puts "=" * 40
pp k.record["unix"][0]["flushmeter"]
puts "=" * 40
pp k.record["cpu_stat"][0]["cpu_stat0"]
=end
