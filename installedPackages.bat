::
:: installedPackages
:: Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
:: MIT Licensed
::

@ECHO OFF

SETLOCAL

SET packages_arch=packages-arch.txt
SET packages_by_user=packages-by-user.txt

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
:GET_PACKAGES_BY_REGKEY

    :: drop the fields at position 1 and 2
    FOR /F "tokens=1,2* delims= " %%a IN ('reg query %1 /s ^| findstr /B ".*DisplayName" ') DO (
        @ECHO %%c >> %2
    )

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the installed packages on an X86 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_PACKAGES_ON_x86

    :: x86(32-bit) packages
    CALL :GET_PACKAGES_BY_REGKEY %regKey_arch% %packages_arch%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the installed packages on an AMD64 system
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_PACKAGES_ON_AMD64

    :: x86(32-bit) packages
    CALL :GET_PACKAGES_BY_REGKEY %regKey_wow6432node% %packages_arch%

    :: AMD64(64-bit) packages
    CALL :GET_PACKAGES_BY_REGKEY %regKey_arch% %packages_arch%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Gets the installed packages from a given architecture
:: @param1 {architecture} - AMD64 or x86
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GET_ALL_INSTALLED_PACKAGES

    :: tidy up
    DEL %packages_arch% > NUL 2>&1
    DEL %packages_by_user% > NUL 2>&1

    CALL :GET_PACKAGES_ON_%1

    :: drop Microsoft/Intel related packages
    FOR /F "tokens=*" %%a IN ('type %packages_arch% ^| findstr /V "Intel" ^| findstr /V "Microsoft" ^| findstr /V "C++" ^| findstr /V "SQL" ^| findstr /V "@"' ) DO (
        @ECHO %%a >> %packages_by_user%
    )

    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::

::CALL :GET_ALL_INSTALLED_PACKAGES AMD64

SET "packages=Java 7:JetBrains MPS:Node.js"

FOR %%S IN ("%packages::=" "%") DO (
    ECHO %%~S
)

ENDLOCAL

