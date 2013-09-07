@echo off

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

