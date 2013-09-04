@echo off

set products=Java Node.js
FOR /F "skip=1 tokens=*" %%i in ('wmic product get Caption') do (
    FOR %%p in (%products%) do (
        echo %%i
    )
)


