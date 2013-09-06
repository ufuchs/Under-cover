@ECHO OFF

SET packages_arch=packages-arch.txt

:: ONLY VALID for AMD64 systems and only exists on them.
:: Contains all installed 32-bit packages on an AMD64 system.
SET regKey_wow6432node=HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall

:: Contains all packages for a given architecture, e.g. x86 or AMD64
:: - On AMD64 systems this key contains one and only the installed 64-bit
::   programs and _not_ the 32bit/x86 programs.
:: - On x86 systems this key contains all installed programs.
SET regKey_Arch=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

GOTO :MAIN

:: Gets the content from an given registry key and write it to the given file.
::
:: @param1 {regKey} String
:: @param2 {filename} String
:GET_PACKAGES_BY_REGKEY

    SETLOCAL

    FOR /F "tokens=1,2* delims= " %%a IN ('reg query %1 /s ^| findstr /B ".*DisplayName" ') DO (
        @ECHO %%c >> %2
    )

    ENDLOCAL
    GOTO :eof

:: Gets the installed packages on an AMD64 system
:GET_PACKAGES_ON_AMD64

    SETLOCAL

    CALL :GET_PACKAGES_BY_REGKEY %regKey_wow6432node% %packages_arch%
    CALL :GET_PACKAGES_BY_REGKEY %regKey_arch% %packages_arch%

    ENDLOCAL
    GOTO :eof

:: Gets the installed packages on an X86 system
:GET_PACKAGES_ON_X86

    SETLOCAL

    CALL :GET_PACKAGES_BY_REGKEY %regKey_arch% %packages_arch%

    ENDLOCAL
    GOTO :eof

:: Gets the installed packages from a given architecture
:: @param1 {architecture} - AMD64 or x86
:GET_PACKAGES

    SETLOCAL

    DEL %packages_arch% > NUL 2>&1
    CALL :GET_PACKAGES_ON_%1

    ENDLOCAL
    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::

CALL :GET_PACKAGES AMD64



