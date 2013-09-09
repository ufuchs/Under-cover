@echo off

GOTO :RUN

:: http://stackoverflow.com/questions/8493493/how-to-loop-thorough-tokens-in-a-string
setlocal EnableDelayedExpansion
set "str=foo bar:biz bang:this & that "^& the other thing!":;How does this work?"
setlocal enableDelayedExpansion
set ^"str=!str::=^

!"
for /f "eol=: delims=" %%S in ("!str!") do (
  if "!!"=="" endlocal
  echo %%S
)

:RUN

:: http://stackoverflow.com/questions/3068929/how-to-read-file-contents-into-a-variable-in-a-batch-file
SETLOCAL EnableDelayedExpansion

SET poi=
SET first=0
FOR /f "Delims=" %%x IN ('type packagesOfInterest.txt') DO (
    IF !first! == 0 (
      SET first=1
      SET poi=%%x
    ) ELSE (
      SET poi=!poi!:%%x
    )
)

ECHO %poi%

goto :eof

SET "str=%pkgOfInterest%"
SET ^"str=!str::=^

!"
FOR /f "eol=: delims=" %%S IN ("!str!") DO (
  IF "!!"=="" ENDLOCAL
  echo %%S
)

