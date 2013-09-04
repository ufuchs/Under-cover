::
:: embeddr-install
:: Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
:: MIT Licensed
::
:: [ I have not failed. I've just found 10,000 ways that won't work. ]
:: [                                            - Thomas A. Edison - ]
::

@ECHO OFF

SETLOCAL EnableDelayedExpansion

:: Batch vars (no edits necessary)
SET base=%~dp0%
SET nodejsPath=%base%node

:: Aquire platform architecture. Gets 'AMD64' or 'x86'
FOR /f "tokens=2* delims= " %%a IN ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v "PROCESSOR_ARCHITECTURE"') DO SET _arch_=%%b

GOTO :MENU

::::::::::::::::::::::::::::::::::::::::
:: SUB ROUTINES
::::::::::::::::::::::::::::::::::::::::

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

    ENDLOCAL
    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MENU
::::::::::::::::::::::::::::::::::::::::

:: CLS
ECHO.
ECHO embeddr-install v0.1
ECHO.

ECHO  1 - Install
ECHO  2 - Exit
ECHO.
SET /P nodejsTask=Choose a task:
ECHO.

IF %nodejsTask% == 1 CALL :INSTALL && GOTO TASK_DONE
IF %nodejsTask% == 2 GOTO LEAVE

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
