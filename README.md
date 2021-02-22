## Notice
Since Solaris is all but dead at this point, this library is no longer being
actively maintained, except perhaps for the occasional doc update. If you
wish to take over maintenance, please send me an email offline and we can
discuss a transfer of the repository.

## Description
A Ruby interface for the Solaris kstat library.

## Prerequisites
Solaris 8 (SunOS 2.8) or later.

## Installation
gem install solaris-kstat

## Synopsis
```ruby
require 'solaris/kstat'
require 'pp'
include Solaris

k = Kstat.new('cpu_info', 0, 'cpu_info0')
pp k.record

{'cpu_info'=>
  {0=>
  {'cpu_info0'=>
    {'chip_id'=>0,
     'fpu_type'=>'sparcv9',
     'device_ID'=>0,
     'cpu_type'=>'sparcv9',
     'implementation'=>'Unknown',
     'clock_MHz'=>502,
     'state_begin'=>1105974702,
     'state'=>'on-line'}
    }
  }
}
```
   
## Singleton Methods
`Kstat.new(module=nil, instance=-1, name=nil)`

Creates and returns a Kstat object. This does not traverse the kstat
chain. The Kstat#record method uses the values passed to actually
retrieve data.

You may specify a module, an instance and a name. The module defaults to
nil (all modules), the instance defaults to -1 (all instances) and the
name defaults to nil (all names).
   
## Instance Methods
`Kstat#record`

Returns a nested hash based on the values passed to the constructor. How
deeply that hash is nested depends on the values passed to the constructor.
The more specific your criterion, the less data you will receive.

## Unsupported names
The following names will not return any meaningful value:

* kstat_headers
* sfmmu_global_stat
* sfmmu_percpu_stat
   
## Known Issues
None.

Please see the Notice at the top regarding the status of this project.

## Designer's Notes
I noticed that results from the cpu_stat module differ from the output
of the 'kstat' command line tool. I am convinced that my code is correct and
that there is a bug in the Solaris::Kstat Perl module. Unfortunately, the
source for the version of the Solaris::Kstat Perl module that works on
Solaris 8 and later is not available (the version on CPAN only works on
Solaris 6 and 7).

See http://tinyurl.com/karxw for more details.
   
## Acknowledgements
Thanks go to Charlie Mills for help with the 'volatile' issue for the original C code.

## Future Plans
None.
   
## License
Artistic-2.0

## Copyright
(C) 2003-2021 Daniel J. Berger
All Rights Reserved

## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.
	 
## Author
Daniel J. Berger
    
## See Also
kstat(1M)
