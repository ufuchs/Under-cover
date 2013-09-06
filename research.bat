@echo off



GOTO :RUN

set products=Java Node.js



:: comannd line
:: FOR /F "tokens=*" %a IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName"') DO @ECHO %a >> cmd.txt
:: ^| findstr /V "Microsoft"

del aaa.txt
FOR /F "tokens=1,2* delims= " %%a IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName" ') DO (
    @ECHO %%c>> aaa.txt
)

del bbb.txt
FOR /F "tokens=*" %%a IN ('type aaa.txt ^| findstr /V "Microsoft" ^| findstr /V "C++" ^| findstr /V "SQL"' ) DO (
    @ECHO %%a >> bbb.txt
)

SET products=Node.js Java JetBrains Graphviz
FOR /F "tokens=1" %%a IN ('type bbb.txt') DO (
        FOR %%i IN (%products%) DO (
            IF %%i==%%a ECHO %%a
        )
)

:processToken

  FOR /F %%a IN ('%line%') DO @ECHO %%a

  GOTO :EOF



:RUN

:: HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
:: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
SET packages_all=packages-all.txt
DEL %packages_all%
FOR /F "tokens=1,2* delims= " %%a IN ('reg query "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName" ') DO (
    @ECHO %%c>> %packages_all%
)

goto :eof

SET packages_reduced=packages-reduced.txt
DEL %packages_reduced%
FOR /F "tokens=*" %%a IN ('type %packages_all% ^| findstr /V "Microsoft" ^| findstr /V "C++" ^| findstr /V "SQL"' ) DO (
    @ECHO %%a >> %packages_reduced%
)


setlocal EnableDelayedExpansion

SET products=Node.js Java JetBrains Graphviz
FOR /F "tokens=1" %%a IN ('type %packages_cleaned%') DO (
        FOR %%i IN (%products%) DO (
            IF %%i==%%a ECHO %%a
        )
)

::
::del ddd.txt
::FOR /F "tokens=*" %%a IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName"') DO @ECHO %%a >> ddd.txt
