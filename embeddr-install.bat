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

SET platform_arch=
SET node_installed=0
SET precheck=0

::::
:: paths
::::

SET base=%~dp0%
SET nodejsPath=%base%node

::::
:: registry keys
::::

SET regKey_Environment=^
    HKLM\System\CurrentControlSet\Control\Session Manager\Environment

GOTO :MAIN

::::::::::::::::::::::::::::::::::::::::
:: SUB ROUTINES
::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Aquire the platform architecture. Gets 'AMD64' or 'x86'
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PLATFORM_ARCHITECTURE

    FOR /f "tokens=2* delims= " %%a IN ('reg query ^
        "%regKey_Environment%" ^
        /v ^
        "PROCESSOR_ARCHITECTURE"') DO SET platform_arch=%%b

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:WINDOWS_VERSION

    SETLOCAL

    ECHO [System - OS-Version]
    FOR /F "tokens=*" %%_ IN ('wmic os get Caption^, OSArchitecture ^
        ^| findstr /I bit') DO ECHO(  %%_

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SWITCH_TO_NODE

    ECHO(
    ECHO(====================
    ECHO(SWITCHING TO Node.js
    ECHO(====================
    ECHO(

    SET node=

    IF %node_installed% EQU 1 (
        SET node=node.exe
    ) ELSE IF %node_installed% EQU 2 (
        SET node=%nodejsPath%\node.exe
    )

    %node% install.js

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRE_CHECK_NETWORK

    SET result=[ ko ]

    ping -n 1 8.8.8.8 > NUL 2>&1

    IF NOT %errorlevel% EQU 0 (
        SET precheck=1 
    ) ELSE (
        SET result=[ OK ]
    )

    < NUL SET /P ^ x="* Check network connection by `ping 8.8.8.8`"

    ECHO(                      %result%

    GOTO :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRE_CHECK_FOR_NODE

    SET result=[ ko ]

    :: invoke global 'nodejs' installation
    node --version > NUL 2>&1

    IF NOT !errorlevel! EQU 0 (

        :: invoke portable 'nodejs' installation
        %nodejsPath%\node.exe --version > NUL 2>&1

        IF NOT !errorlevel! EQU 0 (
            SET precheck=1
        ) ELSE (
            SET node_installed=2
            SET result=[ OK ]
        )

    ) ELSE (
        SET node_installed=1
        SET result=[ OK ]
    )

::    < NUL SET /P ^ x="* Check presense of `node.js`"

::    ECHO(                                     %result%

    GOTO :eof


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PRE_CHECK

    ECHO(
    ECHO(====================
    ECHO(CHECKING PREREQUESTS
    ECHO(====================
    ECHO(    

::    CALL :PRE_CHECK_NETWORK

    IF NOT %precheck% EQU 0 (
        ECHO(
        ECHO(  This script requires a working internet connection.
        ECHO(  Please check this and then come back.
        ECHO(  Terminate execution.
        ECHO(    
        GOTO :LEAVE
    )

    SET precheck=0
    CALL :PRE_CHECK_FOR_NODE

    IF NOT %precheck% EQU 0 (

        ECHO(* 'Node.js' is missing. Try to install.
        ECHO(    

        CALL :INSTALL_NODE_LOCAL

        :: after installation re-run 'PRE_CHECK_FOR_NODE' again
        SET precheck=0
        CALL :PRE_CHECK_FOR_NODE

        IF NOT %precheck% EQU 0 (

            ECHO(
            ECHO(  Node.js can't be invoked.
            ECHO(  Terminate execution.
            ECHO(    

        ) ELSE (

            ECHO(
            ECHO(  Node.js is ready to use.
            ECHO(    

        )

    ) ELSE (

        ECHO(  All things all right.
    )

    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:INSTALL_NODE_LOCAL
::::::::::::::::::::::::::::::::::::::::

    CALL :PLATFORM_ARCHITECTURE

    ECHO(  ^|
    ECHO(  ^| Node.js Portable v1.2
    ECHO(  ^| Copyright(c) 2013 Cr@zy ^<webmaster@crazyws.fr^>
    ECHO(  ^|    

    CALL %base%\win7\nodejs-portable.bat ^
        unattended ^
        %platform_arch%

    GOTO :eof

::::::::::::::::::::::::::::::::::::::::
:MAIN
::::::::::::::::::::::::::::::::::::::::

CALL :PRE_CHECK

IF NOT %precheck% EQU 0 GOTO :LEAVE

CALL :SWITCH_TO_NODE

:LEAVE

ENDLOCAL

