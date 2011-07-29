###############################################################################
# test_solaris_kstat.rb
#
# Test suite for the solaris-kstat Ruby library. You should run this via
# the 'rake test' task.
###############################################################################
require 'rubygems'
gem 'test-unit'

require 'solaris/kstat'
require 'test/unit'
require 'set'
include Solaris

class TC_Solaris_Kstat < Test::Unit::TestCase
  def setup
    @kstat = Kstat.new
  end

  def test_version
    assert_equal('1.0.3', Kstat::VERSION)
  end

  def test_name
    assert_respond_to(@kstat, :name)
    assert_respond_to(@kstat, :name=)
    assert_nil(@kstat.name)
    assert_nothing_raised{ @kstat.name }
    assert_nothing_raised{ @kstat.name = 'foo' }
  end

  def test_module
    assert_respond_to(@kstat, :module)
    assert_respond_to(@kstat, :module=)
    assert_nil(@kstat.module)
    assert_nothing_raised{ @kstat.module }
    assert_nothing_raised{ @kstat.module = 'bar' }
  end

  def test_instance
    assert_respond_to(@kstat, :instance)
    assert_respond_to(@kstat, :instance=)
    assert_nil(@kstat.instance)
    assert_nothing_raised{ @kstat.instance }
    assert_nothing_raised{ @kstat.instance = 0 }
  end

  def test_constructor_valid_values
    assert_nothing_raised{ Kstat.new('cpu_info',0,'cpu_info0').record }
    assert_nothing_raised{ Kstat.new(nil,0,'cpu_info0').record }
    assert_nothing_raised{ Kstat.new('cpu_info',0,nil).record }
  end

  def test_constructor_invalid_values
    assert_raises(Kstat::Error){ Kstat.new('bogus').record }
    assert_raises(Kstat::Error){ Kstat.new('cpu_info',99).record }
    assert_raises(Kstat::Error){ Kstat.new('cpu_info',0,'bogus').record }
    assert_raises(TypeError){ Kstat.new('cpu_info','x').record }
  end

  def test_record_basic
    assert_respond_to(@kstat, :record)
  end

  def test_record_named
    assert_nothing_raised{ @kstat.record['cpu_info'][0]['cpu_info0'] }
    assert_kind_of(Hash, @kstat.record['cpu_info'][0]['cpu_info0'])
  end

  def test_record_io
    assert_nothing_raised{ @kstat.record['nfs'][1]['nfs1'] }
    assert_kind_of(Hash, @kstat.record['nfs'][1]['nfs1'])
  end

  def test_record_intr
    assert_nothing_raised{ @kstat.record['fd'][0]['fd0'] }
    assert_kind_of(Hash, @kstat.record['fd'][0]['fd0'])
  end

  def test_record_raw_vminfo
    keys = %w/class freemem swap_alloc swap_avail swap_free swap_resv/

    assert_nothing_raised{ @kstat.record['unix'][0]['vminfo'] }
    assert_kind_of(Hash, @kstat.record['unix'][0]['vminfo'])
    assert_equal(keys, @kstat.record['unix'][0]['vminfo'].keys.sort)
  end

  def test_record_raw_var
    keys = %w/
      class v_autoup v_buf v_bufhwm v_call v_clist v_hbuf v_hmask
      v_maxpmem v_maxsyspri v_maxup v_maxupttl v_nglobpris v_pbuf
      v_proc v_sptmap
    /

    assert_nothing_raised{ @kstat.record['unix'][0]['var'] }
    assert_kind_of(Hash, @kstat.record['unix'][0]['var'])
    assert_equal(keys,  @kstat.record['unix'][0]['var'].keys.sort)
  end

  def test_record_raw_biostats
    keys = %w/
      buffer_cache_hits
      buffer_cache_lookups
      buffers_locked_by_someone
      class
      duplicate_buffers_found
      new_buffer_requests
      waits_for_buffer_allocs
    /

    assert_nothing_raised{ @kstat.record['unix'][0]['biostats'] }
    assert_kind_of([Hash, NilClass], @kstat.record['unix'][0]['biostats'])
    assert_equal(keys,  @kstat.record['unix'][0]['biostats'].keys.sort)
  end

  def test_record_raw_cpu_stat
    keys = %w/
      class cpu_idle cpu_user cpu_kernel cpu_wait wait_io wait_swap
      wait_pio bread bwrite lread lwrite phread phwrite pswitch
      trap intr syscall sysread syswrite sysfork sysvfork sysexec
      readch writech rcvint xmtint mdmint rawch canch outch msg
      sema namei ufsiget ufsdirblk ufsipage ufsinopage inodeovf
      fileovf procovf intrthread intrblk idlethread inv_swtch
      nthreads cpumigrate xcalls mutex_adenters rw_rdfails
      rw_wrfails modload modunload bawrite
    /

    assert_nothing_raised{ @kstat.record['cpu_stat'][0]['cpu_stat0'] }
    assert_kind_of(Hash, @kstat.record['cpu_stat'][0]['cpu_stat0'])

    # Too big and difficult to sort manually - so use a Set
    set1 = Set.new(keys)
    set2 = Set.new(@kstat.record['cpu_stat'][0]['cpu_stat0'].keys)
    diff = set1 - set2

    assert_equal(set1,set2,'Diff was: #{diff.to_a}')
  end

  def test_record_ncstats
    keys = %w/
      class
      dbl_enters
      enters
      hits
      long_enter
      long_look misses
      move_to_front
      purges
    /

    assert_nothing_raised{ @kstat.record['unix'][0]['ncstats'] }
    assert_kind_of(Hash, @kstat.record['unix'][0]['ncstats'])
    assert_equal(keys, @kstat.record['unix'][0]['ncstats'].keys.sort)
  end

  def test_record_sysinfo
    keys = %w/class runocc runque swpocc swpque updates waiting/

    assert_nothing_raised{ @kstat.record['unix'][0]['sysinfo'] }
    assert_kind_of(Hash, @kstat.record['unix'][0]['sysinfo'])
    assert_equal(keys, @kstat.record['unix'][0]['sysinfo'].keys.sort)
  end

  def test_class_set
    assert_equal("misc", @kstat.record['unix'][0]['sysinfo']['class'])
  end

  def teardown
    @kstat = nil
  end
end
