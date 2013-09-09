::
:: installedSoftware
:: Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
:: MIT Licensed
::

@ECHO OFF

SETLOCAL

SET software_all=software-all.txt
SET software_by_user=software-by-user.txt
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

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the content from a given registry key and write it to the given file.
::
:: @param1 {regKey} String
:: @param2 {filename} String
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_SOFTWARE_BY_REGKEY

    :: drop the fields at position 1 and 2
    FOR /F "tokens=1,2* delims= " %%a IN ('reg query %1 /s ^| findstr /B ".*DisplayName" ') DO (
        :: Be aware! A space between '%%c >>' writes an extra space at the end of each line.
        ECHO %%c>> %2
    )

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the installed packages on an X86 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_SOFTWARE_ON_x86

    :: x86(32-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_arch% %software_all%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the installed packages on an AMD64 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_SOFTWARE_ON_AMD64

    :: x86(32-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_wow6432node% %software_all%

    :: AMD64(64-bit) packages
    CALL :GET_SOFTWARE_BY_REGKEY %regKey_arch% %software_all%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the installed packages from a given architecture
:: @param1 {architecture} - AMD64 or x86
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_SOFTWARE_BY_USER

    :: tidy up
    DEL %software_all% > NUL 2>&1
    DEL %software_by_user% > NUL 2>&1

    CALL :GET_SOFTWARE_ON_%1

    SORT %software_all% /o %software_all%

    :: drop Microsoft/Intel related packages
    FOR /F "tokens=*" %%a IN ('type %software_all% ^| findstr /V "Intel" ^| findstr /V "Microsoft" ^| findstr /V "C++" ^| findstr /V "SQL" ^| findstr /V "@"' ) DO (
        :: Be aware! A space between '%%c >>' writes an extra space at the end of each line.
        ECHO %%a>> %software_by_user%
    )

    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::

:: Aquire platform architecture. Gets 'AMD64' or 'x86'
FOR /f "tokens=2* delims= " %%a IN ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "PROCESSOR_ARCHITECTURE"') DO SET arch=%%b

CALL :GET_SOFTWARE_BY_USER %arch%

SETLOCAL enableDelayedExpansion

:: reads the %software_to_search% file and builds up an search string
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
FOR /F "tokens=*" %%a IN ('type %software_by_user%') DO (
    :: iterates for each installed software package over the software names in the search string
    FOR %%S IN ("%sp::=" "%") DO (
        ECHO %%a | findstr /B "%%~S"
    )
)

ENDLOCAL
