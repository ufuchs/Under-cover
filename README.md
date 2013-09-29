Under-cover
===========

Speciols

* No inbuild string length function.
* Within the body of a FOR loop no multiple line comments are possible.
  In dependency of the context sometimes any single line comment throws an exception.
* Assigning values to a variable within a loop needs a special syntax:
  Instead of writing 
  	%variable% 
  you must use 
    !variable!.
  And the directive 'SETLOCAL enableDelayedExpansion' must set before.
*
