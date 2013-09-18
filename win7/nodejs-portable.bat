@ECHO OFF
SETLOCAL EnableDelayedExpansion

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                                ::
::  Node.js Portable                                                              ::
::                                                                                ::
::  A DOS Batch script to make Node.js portable on Windows systems.               ::
::                                                                                ::
::  Copyright (C) 2013 Cr@zy <webmaster@crazyws.fr>                               ::
::                                                                                ::
::  Node.js Portable is free software; you can redistribute it and/or modify      ::
::  it under the terms of the GNU Lesser General Public License as published by   ::
::  the Free Software Foundation, either version 3 of the License, or             ::
::  (at your option) any later version.                                           ::
::                                                                                ::
::  Node.js Portable is distributed in the hope that it will be useful,           ::
::  but WITHOUT ANY WARRANTY; without even the implied warranty of                ::
::  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                  ::
::  GNU Lesser General Public License for more details.                           ::
::                                                                                ::
::  You should have received a copy of the GNU Lesser General Public License      ::
::  along with this program. If not, see http://www.gnu.org/licenses/.            ::
::                                                                                ::
::  Related post: http://goo.gl/gavL4                                             ::
::  Usage: nodejs-portable.bat [/unattended]                                      ::
::                                                                                ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

TITLE Node.js Portable v1.2

:: Settings
SET nodejsVersion=0.10.18

:: http://stackoverflow.com/questions/1291941/batch-files-number-of-command-line-arguments
SET archDir=
SET arch=%2

IF %arch% EQU AMD64 (
    SET archDir=x64/
    SET arch=x64
)

:: Batch vars (no edits necessary)
SET nodejsPath=%CD%\node
SET nodejsWork=%nodejsPath%\work
SET npmPath=%nodejsPath%\node_modules\npm
SET npmGlobalConfigFilePath=%npmPath%\npmrc
SET nodejsInstallVbs=%TEMP%\nodejs_install.vbs
SET nodejsMsiPackage=node-v%nodejsVersion%-%arch%.msi
SET nodejsUrl=http://nodejs.org/dist/v%nodejsVersion%/%archDir%%nodejsMsiPackage%

:: installMode
:: 1 - menu install
:: 2 - unattended install
SET installMode=1

IF "%1" == "unattended" (
    SET installMode=2
    SET nodejsTask=2
    ECHO(  ^| Url : %nodejsUrl%
    ECHO(  ^| Dest: %nodejsPath%
    ECHO(  ^|
    GOTO INSTALL
) ELSE (
    CLS
)

ECHO Copyright(c) 2013 Cr@zy ^<webmaster@crazyws.fr^>
ECHO LGPL Version3 Licensed
ECHO.

::::::::::::::::::::::::::::::::::::::::
:MENU
::::::::::::::::::::::::::::::::::::::::

ECHO  1 - Launch
ECHO  2 - Install
ECHO  9 - Exit
ECHO.
SET /P nodejsTask=Choose a task:
ECHO.

IF %nodejsTask% == 1 GOTO LAUNCH
IF %nodejsTask% == 2 GOTO INSTALL
IF %nodejsTask% == 9 GOTO EXIT
GOTO MENU

:: http://de.wikibooks.org/wiki/Batch-Programmierung:_Batch-Befehle

::::::::::::::::::::::::::::::::::::::::
:INSTALL
::::::::::::::::::::::::::::::::::::::::

:: Check if node.js is installed
IF EXIST "%nodejsPath%\node.exe" ECHO node.js is already installed... && GOTO EOF

:: Reloacte and create temp dir (workaround for permission issue)
SET TEMP=%nodejsPath%\tmp
IF NOT EXIST "%TEMP%" MKDIR "%TEMP%"

:: Prepare cscript to download node.js
ECHO WScript.StdOut.Write "  | Download " >%nodejsInstallVbs%
:: Switched to 'WinHttp.WinHttpRequest.5.1'
ECHO dim http: set http = createobject("WinHttp.WinHttpRequest.5.1") >>%nodejsInstallVbs%
ECHO dim bStrm: set bStrm = createobject("Adodb.Stream") >>%nodejsInstallVbs%
:: Open in asynchronous mode.
ECHO http.Open "GET", "%nodejsUrl%", True >>%nodejsInstallVbs%
ECHO http.Send >>%nodejsInstallVbs%
:: Every second write a '.' until the download is complete
ECHO while http.WaitForResponse(0) = 0 >>%nodejsInstallVbs%
ECHO   WScript.StdOut.Write "." >>%nodejsInstallVbs%
ECHO   WScript.Sleep 1000 >>%nodejsInstallVbs%
ECHO wend >>%nodejsInstallVbs%
:: ECHO WScript.StdOut.Write vbCRLF >>%nodejsInstallVbs%
:: Write the HTTP status code onto console
ECHO WScript.StdOut.WriteLine " [HTTP " ^& http.Status ^& " " ^& http.StatusText ^& "]" >>%nodejsInstallVbs%
ECHO WScript.StdOut.Write "  " >>%nodejsInstallVbs%
ECHO with bStrm >>%nodejsInstallVbs%
ECHO .type = 1 '//binary >>%nodejsInstallVbs%
ECHO .open >>%nodejsInstallVbs%
ECHO .write http.responseBody >>%nodejsInstallVbs%
ECHO .savetofile "%TEMP%\%nodejsMsiPackage%", 2 >>%nodejsInstallVbs%
ECHO end with >>%nodejsInstallVbs%

:: Download latest version in the current folder
cscript.exe /NoLogo %nodejsInstallVbs%

IF NOT EXIST "%TEMP%\%nodejsMsiPackage%" (

    ECHO(  ^| Download failed
    ECHO(  ^|  
    GOTO :EXIT
)

:: Extract the MSI package
::ECHO Install node.js in %nodejsPath%...
:: ECHO ^  Installing ...
<nul (set/p z=  Installing ... )
msiexec /a "%TEMP%\%nodejsMsiPackage%" /qn TARGETDIR="%nodejsPath%"

IF %installMode% == 1 (
    XCOPY "%nodejsPath%\nodejs" "%nodejsPath%" /s /e /i /h /y
) ELSE (
    XCOPY "%nodejsPath%\nodejs" "%nodejsPath%" /s /e /i /h /y > NUL
)

:: Clean folders
RMDIR /s /q "%nodejsPath%\nodejs"
RMDIR /s /q "%TEMP%"
IF EXIST "%nodejsPath%\%nodejsMsiPackage%" DEL "%nodejsPath%\%nodejsMsiPackage%"

:: http://stackoverflow.com/questions/368041/how-to-code-a-spinner-for-waiting-processes-in-a-batch-file
:: http://www.dostips.com/forum/viewtopic.php?f=3&t=2124
IF EXIST "%nodejsPath%\node.exe" @<NUL (SET/P z=[ OK ])
IF NOT EXIST "%nodejsPath%\node.exe" ECHO An error occurred during the installation.
GOTO PREPARE


::::::::::::::::::::::::::::::::::::::::
:LAUNCH
::::::::::::::::::::::::::::::::::::::::

:: Check if node.js is installed
IF NOT EXIST "%nodejsPath%\node.exe" ECHO node.js is not installed... Please install first... && GOTO EOF
IF NOT %nodejsTask% == 0 GOTO PREPARE

:: Init node vars
cmd.exe /k "cd %nodejsWork% && %nodejsPath%\nodevars.bat && %nodejsPath%\npm config set globalconfig %npmGlobalConfigFilePath% --global"
GOTO MENU



::::::::::::::::::::::::::::::::::::::::
:PREPARE
::::::::::::::::::::::::::::::::::::::::

:: Relocate and edit NPM global config file
ECHO prefix = %nodejsPath%\ >%npmGlobalConfigFilePath%
ECHO globalconfig = %npmPath%\npmrc >>%npmGlobalConfigFilePath%
ECHO globalignorefile = %npmPath%\npmignore >>%npmGlobalConfigFilePath%
ECHO init-module = %npmPath%\init.js >>%npmGlobalConfigFilePath%
ECHO cache = %npmPath%\cache >>%npmGlobalConfigFilePath%

IF NOT EXIST "%nodejsWork%" MKDIR "%nodejsWork%"
IF NOT EXIST "%npmPath%\npmignore" ECHO. 2>"%npmPath%\npmignore"
IF NOT EXIST "%npmPath%\init.js" ECHO. 2>"%npmPath%\init.js"
IF NOT EXIST "%npmPath%\cache" MKDIR "%npmPath%\cache"
IF %nodejsTask% == 1 SET nodejsTask=0

IF %installMode% == 2 (
    GOTO EXIT
) ELSE (
    GOTO LAUNCH
)


::::::::::::::::::::::::::::::::::::::::
:EOF
::::::::::::::::::::::::::::::::::::::::

ECHO.
PAUSE
GOTO MENU



::::::::::::::::::::::::::::::::::::::::
:EXIT
::::::::::::::::::::::::::::::::::::::::

ENDLOCAL
