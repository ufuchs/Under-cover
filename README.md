Windows7-Whats-installed
========================

Case study concerning the scripting capability on Windows 7 with traditionally batch file.

NOTE:

  Please be aware of the correct line endings, CRLF in this case.
  Otherwise the script will fail!

Subsequent experiences have been taken:

PRO:
* Sub routines are possible
* Self-Generating incl. invoking of script files are possible. See 'temp/software-we-will-exclude.bat' after first run.


CONS:
* No inbuild string length function.
* Within the body of a FOR loop no multiple line comments are possible.
  In dependency of the context sometimes any single line comment throws an exception.
* Assigning values to a variable within a loop needs a special syntax:
  Instead of writing
  	%variable%
  you must use
    !variable!.
  And the directive 'SETLOCAL enableDelayedExpansion' must set before.

