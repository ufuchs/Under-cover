::
:: whats-installed
:: Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
:: MIT Licensed
::
:: [ I have not failed. I've just found 10,000 ways that won't work. ]
:: [                                            - Thomas A. Edison - ]

@ECHO OFF

SETLOCAL

GOTO :ENTRY

::::
:: script template
::::

:: script tmplate for 'software_we_will_exclude.bat'
__OUT_OF_SCOPE__
@ECHO OFF
::
:: Don't edit this file.
:: It will overwritten by the next run.
:: Any changes should be made in 'confige\software_we_will_exclude.txt'.
::
FOR /F "tokens=*" %%_ IN ('type %1 ^
    ') DO (
    ECHO %%_>> %2
)
__EPOCS_FO_TUO__

:ENTRY

::::
:: common 
::::

SET proc_arch=

::::
:: paths
::::

SET base=%~dp0%

SET config=%base%config

SET temp=%base%temp

IF NOT EXIST %temp% MKDIR %temp%

::::
:: config files
::::

SET software_we_are_looking_for=^
    %config%\software-we-are-looking-for.txt

SET exclude_from_scope=software-we-will-exclude

SET exclude_from_scope_txt=^
    %config%\%exclude_from_scope%.txt

::::
:: artifact files
::::

SET installed_full_house=^
    %temp%\software-on-system.txt

SET installed_in_scope=^
    %temp%\software-in-scope.txt

SET exclude_from_scope_bat=^
    %temp%\%exclude_from_scope%.bat

SET software_present=^
    software-present.txt

SET software_missing=^
    software-missing.txt

::::
:: registry keys
::::

:: ONLY VALID for AMD64 systems and only exists on them.
:: Contains all installed 32-bit packages on an AMD64 system.
SET regKey_wow6432node=^
    HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall

:: Contains the packages for a given architecture, e.g. x86 or AMD64
:: - On AMD64 systems this key contains one and only the installed 64-bit
::   programs and _not_ the 32bit/x86 programs.
:: - On x86 systems this key contains all installed programs.
SET regKey_arch=^
    HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

SET regKey_Environment=^
    HKLM\System\CurrentControlSet\Control\Session Manager\Environment

GOTO :MAIN

::
:: SUBROUTINES
::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Writes the installed Windows version
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:WRITE_WINDOWS_VERSION

    ECHO(  [System]
    FOR /F "tokens=*" %%_ IN ('wmic os get Caption^, OSArchitecture ^
        ^| findstr /I bit') DO (
        ECHO(    %%_
    )
    ECHO(

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the processor architecture. Gets 'AMD64' or 'x86'
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PROCESSOR_ARCHITECTURE

    FOR /f "tokens=2* delims= " %%a IN ('reg query ^
        "%regKey_Environment%" ^
        /v ^
        "PROCESSOR_ARCHITECTURE"') DO SET proc_arch=%%b

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the content from a given registry key and write it to the given file.
::
:: @param1 {regKey} String
:: @param2 {filename} String
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_SOFTWARE_BY_REGKEY

    :: drop the unnecessary fields at position 1 and 2
    FOR /F "tokens=1,2* delims= " %%a IN ('reg query %1 /s ^
        ^| findstr /B ".*DisplayName" ') DO (
        :: A space between '%%c >>' writes an extra space at line end
        ECHO %%c>> %2
    )

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets all installed software on a X86 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_INSTALLED_SOFTWARE_ON_x86

    :: x86(32-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY ^
        %regKey_arch% ^
        %installed_full_house%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets all installed software on an AMD64 system
:: On AMD64 systems the 32-bit software lies under 'wow6432node' 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_INSTALLED_SOFTWARE_ON_AMD64

    :: x86(32-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY ^
        %regKey_wow6432node% ^
        %installed_full_house%

    :: AMD64(64-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY ^
        %regKey_arch% ^
        %installed_full_house%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Reading from the registry gets duplicated enties.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:REMOVE_DUPLICATE_ENTRIES

    SETLOCAL

    SORT %installed_full_house% /o %installed_full_house%

    :: drop duplicates
    SET line=
    SET prevLine=
    FOR /f "tokens=* delims=" %%_ IN (%installed_full_house%) DO (
        IF %%_ NEQ !prevLine! (
          ECHO %%_>> temp.txt
          SET prevLine=%%_
        )
    )

    COPY /V /Y temp.txt %installed_full_house% > NUL 2>&1

    DEL temp.txt

    ENDLOCAL

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Builds a script which removes unwished packages from %installed_full_house%
:: It can be configured by 'exclude-from-scope.txt'
::
:: @param1 {scriptname} String
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CREATE_SCRIPT_EXCLUDE_FROM_SCOPE

    SETLOCAL

    SET line=

    DEL %exclude_from_scope_bat% > NUL 2>&1

    ::
    :: Write the script code
    ::
    FOR /f "useback delims=" %%_ IN (%1) do (
        IF "%%_" EQU "__EPOCS_FO_TUO__" (
            :: leave the subroutine
            SET $=
            ENDLOCAL
            GOTO :eof
        )
        IF !$! EQU 3 (
            ECHO(%%_>> %exclude_from_scope_bat%
        ) ELSE IF !$! EQU 2 (
            FOR /F "tokens=*" %%# IN (%exclude_from_scope_txt%) DO (
                SET x=%%#
                SET y=!x:~0,2%!
                :: excludes comments inside of %exclude_from_scope%
                IF !y! NEQ :: (
                    SET "line=    ^| findstr /V "%%#" ^"
                    ECHO !line!>> %exclude_from_scope_bat%
                )
            )
            ECHO %%_>> %exclude_from_scope_bat%
            SET $=3
        ) ELSE IF !$! EQU 1 (
            :: write comments at the begin of %exclude_from_scope_script%
            SET x=%%_
            SET y=!x:~0,3%!
            ECHO %%_>> %exclude_from_scope_bat%
            IF !y! EQU FOR (
                SET $=2
            )
        ) ELSE IF "%%_" EQU "__OUT_OF_SCOPE__" (
            SET $=1
        )
    )

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the complete list of the installed software.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_INSTALLED_SOFTWARE

    :: delete files from last run
    DEL %installed_full_house% > NUL 2>&1
    DEL %installed_in_scope% > NUL 2>&1

    ECHO(
    ECHO(  Looking for installed software in the registry ...
    ECHO(

    CALL :WRITE_WINDOWS_VERSION

    CALL :PROCESSOR_ARCHITECTURE

    CALL :GET_INSTALLED_SOFTWARE_ON_%proc_arch%

    CALL :REMOVE_DUPLICATE_ENTRIES

    ::  To increase the performance, all software entries out of scope/interest
    ::+ should be removed.
    ::+ The output is written into %installed_in_scope%
    CALL %exclude_from_scope_bat% ^
        %installed_full_house% ^
        %installed_in_scope%

    GOTO :eof

:: CHECK comment
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  Transforms the content of the file %software_we_are_looking_for% into 
::+ an internal string representation delimited by ':'
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SOFTWARE_WE_ARE_LOOKING_FOR

    ::  reads the %software_we_are_looking_for% file
    ::+ and lines up the items separated by ':'
    FOR /f "Delims=" %%_ IN (%software_we_are_looking_for%) DO (
        SET swalf=!swalf!%%_:
    )

    IF DEFINED swalf (
        :: drop the last ':'
        SET swalf=!swalf:~0,-1!
    )

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:REPORT_PREAMPLE

    ECHO(  ======================
    ECHO(  THE FOLLOWING SOFTWARE
    ECHO(  ======================
    ECHO(
    ECHO(  [as desired is]

    FOR /f %%_ IN (%software_we_are_looking_for%) DO (
        ECHO(    %%_
    )

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:REPORT_SOFTWARE_PRESENT_IN_REGISTRY

    SETLOCAL

    DEL %software_present% > NUL 2>&1

    ECHO(
    ECHO(  [present]

    :: look up for the software to search
    SET "sp=%swalf%"
    FOR /F "tokens=*" %%_ IN (%installed_in_scope%) DO (
        :: iterates over the software names in the search string for each installed software package
        FOR %%# IN ("%sp::=" "%") DO (
            ECHO.%%_ | findstr /B %%# > NUL
            IF !errorlevel! EQU 0 (
                :: write to console
                ECHO.    %%_
                (
                    ECHO %%_>> %software_present%
                )
            )
        )
    )

    ENDLOCAL

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:REPORT_SOFTWARE_MISSING_IN_REGISTRY

    SETLOCAL

    DEL %software_missing% > NUL 2>&1

    ECHO(
    ECHO(  [missing]

    :: http://stackoverflow.com/questions/11461432/batch-file-to-compare-contents-of-a-text-file
    FOR /f %%i in (%software_present%) DO SET %%i=%%i
    FOR /f %%j in (%software_we_are_looking_for%) DO IF NOT DEFINED %%j (
        ECHO(    %%j
        ECHO(%%j>> %software_missing%
    )

    ECHO(
    ECHO(    
    ECHO(  All installed software can be found in 
    ECHO(    
    ECHO(    'temp\software-on-system.txt'


    ENDLOCAL

    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::

SETLOCAL enableDelayedExpansion

CALL :SOFTWARE_WE_ARE_LOOKING_FOR

CALL :CREATE_SCRIPT_EXCLUDE_FROM_SCOPE ^
    %0

:: Fetch the installed software
CALL :GET_INSTALLED_SOFTWARE

CALL :REPORT_PREAMPLE

CALL :REPORT_SOFTWARE_PRESENT_IN_REGISTRY

CALL :REPORT_SOFTWARE_MISSING_IN_REGISTRY

ENDLOCAL
