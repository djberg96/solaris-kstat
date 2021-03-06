## 1.1.2 - 18-Dec-2015
* This gem is now signed.
* The Rakefile now assumes Rubygems 2.x for gem related tasks.
* Added a solaris-kstat.rb file for convenience.

## 1.1.1 - 2-Nov-2014
* Use relative_require instead of manual method.
* Minor updates to the Rakefile and gemspec.

## 1.1.0 - 13-Oct-2013
* Converted code to use FFI.
* The Kstat::Error subclass was removed. Any internal FFI
  functions that fail raise a SystemCallError instead.
* Refactored the test suite, and added some tests for FFI structs.
* Added test-unit 2 and rake as development dependencies.

## 1.0.3 - 30-Jul-2011
* Added test-unit as a development dependency.
* Fixed a switch statement bug (missing break).

## 1.0.2 - 29-Jul-2011
* Fixed a bug where the name hash keys could potentially be overwritten if there
  were multiple statistics for the same name. Thanks go to Jens Deppe for the
  spot and the patch.
* Added the "class" information to the statistics hash.
* Rakefile refactored. The old style of library installation has been removed.
  Use the 'gem' tasks now. In addition, gem creation is now handled via a Rake
  task now.
* Some minor modifications to the gemspec to reflect the changes in the
  Rakefile, as well as a change required due to the switch from CVS to git.
* Added a .gitignore file.
* Changed license to Artistic 2.0.

## 1.0.1 - 27-Aug-2009
* Changed the license to Artistic 2.0.
* Fixed warnings that could occur if the @module, @name, or @instance
  variables were not set in the constructor. They are now explicitly
  set to nil if they do not have any value.
* Updates to the gemspec, including license and description.
* Renamed and performed some minor refactoring of the test and example files.
* Changed one test to use 'biostats' instead of 'flushmeter' because
  the latter does not appear to be defined in a Solaris VM.
* Added the 'example' rake task.

## 1.0.0 - 4-Feb-2008
* Updated the extconf.rb file so that it sets the target prefix properly.
* Version bump to 1.0.0.
* No actual source code changes.

## 0.2.3 - 23-Jul-2007
* KstatError is now Kstat::Error.
* Documentation improvements and updates.
* Added a Rakefile with tasks for installation and testing.
* Added a dir_config('kstat') to the extconf.rb file in case you should need it.
* Internal project layout and code cleanup changes that you don't care about.

## 0.2.2 - 10-Jul-2006
* Updated the gemspec (and put a gem out on RubyForge).

## 0.2.1 - 31-Mar-2005
* Added some taint checking for string arguments.
* Added better error messages for various kstat related C function failures.
* Made this document rdoc friendly.
* Modified the test suite slightly because the "ifb" module is not, in fact,
  found on all Solaris systems.
* Added a gemspec.
* Added more tests.
* Added an acknowledgement.
* Removed the kstat.txt and kstat.rd files.  The documentation is now
  located in the README file, though the source files are still rdoc friendly.

## 0.2.0 - 18-Jan-2005
* Altered the API to accept a module, instance and name.  This release is
  still backwards compatable with the 0.1.x version.
* Added Kstat#module, Kstat#instance and Kstat#name.
* Documentation updates
* More tests added

## 0.1.1 - 9-Nov-2004
* Added support for the cpu_stat module.
* Moved 'examples' to toplevel directory.
* Some attempts made to make documentation more rdoc friendly.

## 0.1.0 - 6-Oct-2004
* Initial release
