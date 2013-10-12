require 'test-unit'
require 'mkmf/lite'
require 'solaris/kstat/structs'

class StructTest < Test::Unit::TestCase
  include Mkmf::Lite
  include Solaris::Structs

  test "KstatCtl struct is the proper size" do
    assert_equal(KstatCtl.size, check_sizeof('kstat_ctl_t', 'kstat.h'))
  end

  test "KstatStruct struct is the proper size" do
    assert_equal(KstatStruct.size, check_sizeof('kstat_t', 'kstat.h'))
  end

  test "KstatNamed struct is the proper size" do
    assert_equal(KstatNamed.size, check_sizeof('kstat_named_t', 'kstat.h'))
  end

  test "Vminfo struct is the proper size" do
    assert_equal(Vminfo.size, check_sizeof('vminfo_t', 'sys/sysinfo.h'))
  end

  test "Flushmeter struct is the proper size" do
    assert_equal(Flushmeter.size, check_sizeof('struct flushmeter', 'sys/vmmeter.h'))
  end

  #test "NcStats struct is the proper size" do
  #  assert_equal(NcStats.size, check_sizeof('struct nc_stats', 'sys/dnlc.h'))
  #end

  test "Sysinfo struct is the proper size" do
    assert_equal(Sysinfo.size, check_sizeof('sysinfo_t', 'sys/sysinfo.h'))
  end

  test "Var struct is the proper size" do
    assert_equal(Var.size, check_sizeof('struct var', 'sys/var.h'))
  end

  test "KstatIntr struct is the proper size" do
    assert_equal(KstatIntr.size, check_sizeof('kstat_intr_t', 'sys/kstat.h'))
  end

  test "KstatIo struct is the proper size" do
    assert_equal(KstatIo.size, check_sizeof('kstat_io_t', 'sys/kstat.h'))
  end

  test "KstatTimer struct is the proper size" do
    assert_equal(KstatTimer.size, check_sizeof('kstat_timer_t', 'sys/kstat.h'))
  end

  test "CpuSysinfo struct is the proper size" do
    assert_equal(CpuSysinfo.size, check_sizeof('cpu_sysinfo_t', 'sys/sysinfo.h'))
  end

  #test "Mntinfo struct is the proper size" do
  #  assert_equal(Mntinfo.size, check_sizeof('struct mntinfo_kstat', 'nfs/nfs_clnt.h'))
  #end
end
