::
:: embeddr-install
:: Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
:: MIT Licensed
::
:: [ I have not failed. I've just found 10,000 ways that won't work. ]
:: [                                            - Thomas A. Edison - ]
::

@ECHO OFF

:: SETLOCAL EnableDelayedExpansion

:: Batch vars (no edits necessary)
SET base=%~dp0%
SET nodejsPath=%base%node

< NUL COPY /Y NUL bbb.txt > NUL
FOR /F "tokens=*" %%a IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName"') DO ECHO %%a >> bbb.txt

:: Aquire platform architecture. Gets 'AMD64' or 'x86'
FOR /f "tokens=2* delims= " %%a IN ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "PROCESSOR_ARCHITECTURE"') DO SET _arch_=%%b

ECHO.
CALL :WINDOWS_VERSION

GOTO :MENU

::::::::::::::::::::::::::::::::::::::::
:: SUB ROUTINES
::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::
:WINDOWS_VERSION
::::::::::::::::::::::::::::::::::::::::

    SETLOCAL

    ECHO [System - OS-Version]
    FOR /F "tokens=*" %%a IN ('wmic os get Caption^, OSArchitecture ^| findstr /I bit') DO ECHO ^  %%a

    ENDLOCAL
    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:INSTALL
::::::::::::::::::::::::::::::::::::::::

    SETLOCAL

    :: Check if node.js is installed
    IF NOT EXIST "%nodejsPath%\node.exe" (
        CALL :INSTALL_NODE
    )

    %nodejsPath%\node.exe %base%\install.js

    ENDLOCAL
    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:INSTALL_NODE
::::::::::::::::::::::::::::::::::::::::

    SETLOCAL

    SET nodejs_arch=%_arch_%
    IF "%_arch_%" EQU "AMD64" SET nodejs_arch=x64

    CALL %base%\win7\nodejs-portable.bat unattended %nodejs_arch%

    ECHO ^  Download and installation managed by 'nodejs-portable'
    ECHO ^  Copyright(c) 2013 Cr@zy ^<webmaster@crazyws.fr^>

    ENDLOCAL
    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:CHECK_FOR_INSTALLED_PACKAGES
::::::::::::::::::::::::::::::::::::::::

    SETLOCAL

::    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s | findstr /B ".*DisplayName" > installed-raw.txt
::    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s  > installed-raw.txt
::    < NUL COPY /Y NUL installed-raw.txt > NUL
::    FOR /F "tokens=*" %%a IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName"') DO ECHO %%a >> installed-raw.txt

    < NUL COPY /Y NUL bbb.txt > NUL
    FOR /F "tokens=*" %%a IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName"') DO ECHO %%a >> bbb.txt

    < NUL COPY /Y NUL installed.txt > NUL
    FOR /F "tokens=1,2* delims= " %%a IN ('TYPE installed-raw.txt') DO ECHO %%c >> installed.txt

    ENDLOCAL
    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MENU
::::::::::::::::::::::::::::::::::::::::

:: CLS

ECHO.
ECHO  1 - PreCheck
ECHO  2 - Install
ECHO  3 - Exit
ECHO.
SET /P nodejsTask=Choose a task:
ECHO.

IF %nodejsTask% == 1 CALL :CHECK_FOR_INSTALLED_PACKAGES && GOTO TASK_DONE
IF %nodejsTask% == 2 CALL :INSTALL && GOTO TASK_DONE
IF %nodejsTask% == 3 GOTO LEAVE

::::::::::::::::::::::::::::::::::::::::
:TASK_DONE
::::::::::::::::::::::::::::::::::::::::

ECHO.
PAUSE
GOTO MENU

::::::::::::::::::::::::::::::::::::::::
:LEAVE
::::::::::::::::::::::::::::::::::::::::

ENDLOCAL

:: java -version 2>&1 | findstr SE
