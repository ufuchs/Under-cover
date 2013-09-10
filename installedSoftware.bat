::
:: installedSoftware
:: Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
:: MIT Licensed
::

@ECHO OFF

SETLOCAL

SET platform_arch=
SET software_all=software-all.txt
SET software_in_scope=software-by-user.txt
SET software_to_search=software-to-search.txt

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
:: SUBROUTINES
::

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
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_arch% %software_all%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets _all_ installed software packages on an AMD64 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_ALL_SOFTWARE_PACKAGES_FOR_AMD64

    :: x86(32-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_wow6432node% %software_all%

    :: AMD64(64-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_arch% %software_all%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Reading from the registry gets duplicated enties.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:REMOVE_DUPLICATE_ENTRIES

    SETLOCAL enableDelayedExpansion

    SORT %software_all% /o %software_all%

    :: drop duplicates
    SET line=
    SET prevLine=
    FOR /f "tokens=* delims=" %%x IN ('type %software_all%') DO (
        SET line=%%x
        IF !line! NEQ !prevLine! (
          ECHO !line!>> temp.txt
          SET prevLine=!line!
        )
    )

    COPY /V /Y temp.txt %software_all% > NUL 2>&1

    DEL temp.txt

    ENDLOCAL

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: To increase the performance, all software entries out of scope/interest
:: should be removed.
:: The output is written into %software_in_scope%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:EXCLUDE_SOFTWARE_OUT_OF_SCOPE

    SETLOCAL

    FOR /F "tokens=*" %%a IN ('type %software_all% ^
        ^| findstr /V "Intel" ^
        ^| findstr /V "Microsoft"
        ^| findstr /V "C++" ^
        ^| findstr /V "SQL" ^
        ^| findstr /V "@"' ) DO (
        :: A space between '%%c >>' writes an extra space at line end
        ECHO %%a>> %software_in_scope%
    )

    ENDLOCAL

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the software packages which should be scanned.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_SOFTWARE_IN_SCOPE

    SETLOCAL enableDelayedExpansion

    :: delete files from last run
    DEL %software_all% > NUL 2>&1
    DEL %software_in_scope% > NUL 2>&1

    CALL :GET_PLATFORM_ARCHITECTURE

    CALL :GET_ALL_SOFTWARE_PACKAGES_FOR_%platform_arch%

    CALL :REMOVE_DUPLICATE_ENTRIES

    CALL :EXCLUDE_SOFTWARE_OUT_OF_SCOPE

    ENDLOCAL

    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::

:: Fetch the installed software
CALL :GET_SOFTWARE_IN_SCOPE

SETLOCAL enableDelayedExpansion

:: reads the %software_to_search% file and lines up the items separated by ':'
SET sts=
SET first=0
FOR /f "Delims=" %%x IN ('type %software_to_search%') DO (
    IF !first! == 0 (
      SET first=1
      SET sts=%%x
    ) ELSE (
      SET sts=!sts!:%%x
    )
)

:: look up for the software to search
SET "sp=%sts%"
FOR /F "tokens=*" %%a IN ('type %software_in_scope%') DO (
    :: iterates over the software names in the search string for each installed software package
    FOR %%S IN ("%sp::=" "%") DO (
        ECHO %%a | findstr /B "%%~S"
    )
)

ENDLOCAL
