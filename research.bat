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

set Build=
for /f "Tokens=* Delims=" %%x in ('type packages-by-user.txt') do set Build=!Build!%%x:

echo %Build%

