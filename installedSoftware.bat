::
:: installedSoftware
:: Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
:: MIT Licensed
::

@ECHO OFF

SETLOCAL

SET platform_arch=

SET installed_full_house=installed-full-house.txt

SET installed_in_scope=installed-in-scope.txt

SET software_to_search=software-to-search.txt

SET installed_exclude_from_scope=installed-exclude-from-scope.txt

SET exclude_from_scope=exclude-from-scope

SET exclude_from_scope_script=%exclude_from_scope%.bat

:: ONLY VALID for AMD64 systems and only exists on them.
:: Contains all installed 32-bit packages on an AMD64 system.
SET regKey_wow6432node=HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall

:: Contains the packages for a given architecture, e.g. x86 or AMD64
:: - On AMD64 systems this key contains one and only the installed 64-bit
::   programs and _not_ the 32bit/x86 programs.
:: - On x86 systems this key contains all installed programs.
SET regKey_arch=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

GOTO :MAIN

::
:: DATA SECTION
::

__OUT_OF_SCOPE__
@ECHO OFF

::
:: Don't edit this file.
:: It will overwritten by the next run.
:: Any changes should be made in 'exclude_from_scope.txt'.
::

FOR /F "tokens=*" %%_ IN ('type %1 ^
    ') DO (
    ECHO %%_>> %2
)
__EPOCS_FO_TUO__

::
:: SUBROUTINES
::

::::::::::::::::::::::::::::::::::::::::
:WINDOWS_VERSION
::::::::::::::::::::::::::::::::::::::::

    SETLOCAL

    ECHO [System - OS-Version]
    ECHO(
    FOR /F "tokens=*" %%_ IN ('wmic os get Caption^, OSArchitecture ^
        ^| findstr /I bit') DO ECHO ^  %%_

    ENDLOCAL

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Aquire the platform architecture. Gets 'AMD64' or 'x86'
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_PLATFORM_ARCHITECTURE

    FOR /f "tokens=2* delims= " %%a IN ('reg query ^
        "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" ^
        /v ^
        "PROCESSOR_ARCHITECTURE"') DO SET platform_arch=%%b

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
:: Gets _all_ installed software packages on an X86 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_ALL_SOFTWARE_PACKAGES_FOR_x86

    :: x86(32-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_arch% %installed_full_house%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets _all_ installed software packages on an AMD64 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_ALL_SOFTWARE_PACKAGES_FOR_AMD64

    :: x86(32-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_wow6432node% %installed_full_house%

    :: AMD64(64-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_arch% %installed_full_house%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Reading from the registry gets duplicated enties.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:REMOVE_DUPLICATE_ENTRIES

    SETLOCAL enableDelayedExpansion

    SORT %installed_full_house% /o %installed_full_house%

    :: drop duplicates
    SET line=
    SET prevLine=
    FOR /f "tokens=* delims=" %%_ IN ('type %installed_full_house%') DO (
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
:CREATE_SCRIPT_EXCLUDE_FROM_SCOPE_SCRIPT

    SETLOCAL EnableDelayedExpansion

    SET line=

    DEL %exclude_from_scope_script% > NUL 2>&1

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
            ECHO(%%_>> %exclude_from_scope_script%
        ) ELSE IF !$! EQU 2 (
            FOR /F "tokens=*" %%# IN ('type %exclude_from_scope%.txt') DO (
                SET x=%%#
                SET y=!x:~0,2%!
                :: exclude comments
                IF !y! NEQ :: (
                    SET "line=    ^| findstr /V "%%#" ^"
                    ECHO !line!>> %exclude_from_scope_script%
                )
            )
            ECHO %%_>> %exclude_from_scope_script%
            SET $=3
        ) ELSE IF !$! EQU 1 (
            :: write header comments
            SET x=%%_
            SET y=!x:~0,3%!
            ECHO %%_>> %exclude_from_scope_script%
            IF !y! EQU FOR (
                SET $=2
            )
        ) ELSE IF "%%_" EQU "__OUT_OF_SCOPE__" (
            SET $=1
        )
    )

    ENDLOCAL

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: To increase the performance, all software entries out of scope/interest
:: should be removed.
:: The output is written into %installed_in_scope%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:EXCLUDE_FROM_SCOPE

    SETLOCAL

    CALL %exclude_from_scope_script% ^
        %installed_full_house% ^
        %installed_in_scope%

    ENDLOCAL

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the software packages which should be scanned.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_INSTALLED_SOFTWARE

    SETLOCAL enableDelayedExpansion

    :: delete files from last run
    DEL %installed_full_house% > NUL 2>&1
    DEL %installed_in_scope% > NUL 2>&1

    CALL :GET_PLATFORM_ARCHITECTURE

    CALL :GET_ALL_SOFTWARE_PACKAGES_FOR_%platform_arch%

    CALL :REMOVE_DUPLICATE_ENTRIES

    CALL :EXCLUDE_FROM_SCOPE

    ENDLOCAL

    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::

SETLOCAL enableDelayedExpansion

CALL :WINDOWS_VERSION

ECHO(
ECHO ^  Aquire installed software from registry.
ECHO ^  This may take a while...
ECHO(

CALL :CREATE_SCRIPT_EXCLUDE_FROM_SCOPE_SCRIPT %0

:: Fetch the installed software
CALL :GET_INSTALLED_SOFTWARE

:: reads the %software_to_search% file and lines up the items separated by ':'
SET sts=
SET first=0
FOR /f "Delims=" %%_ IN ('type %software_to_search%') DO (
    IF !first! == 0 (
      SET first=1
      SET sts=%%_
    ) ELSE (
      SET sts=!sts!:%%_
    )
)

ECHO(
ECHO ^  Following software is installed:
ECHO ^  ================================
ECHO(

:: look up for the software to search
SET "sp=%sts%"
FOR /F "tokens=*" %%_ IN ('type %installed_in_scope%') DO (
    :: iterates over the software names in the search string for each installed software package
    FOR %%# IN ("%sp::=" "%") DO (
        ECHO %%_ | findstr /B %%#
    )
)

::type test.txt

ENDLOCAL
