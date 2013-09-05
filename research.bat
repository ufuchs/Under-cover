@echo off

GOTO :RUN

set products=Java Node.js
FOR /F "skip=1 tokens=*" %%i in ('wmic product get Caption') do (
    FOR %%p in (%products%) do (
        echo %%i
    )
)

:RUN

FOR /F "tokens=*" %%a IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s ^| findstr /B ".*DisplayName"') DO ECHO %%a >> bbb.txt

