@echo off

GOTO :RUN

:: http://stackoverflow.com/questions/3068929/how-to-read-file-contents-into-a-variable-in-a-batch-file

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

   "FOR /F "tokens=*" %a IN ('type  ^"
   "    ^| findstr /V "Intel" ^"
   "    ^| findstr /V "Microsoft" ^"
   "    ^| findstr /V "C++" ^"
   "    ^| findstr /V "SQL" ^"
   "    ^| findstr /V "@"' ) DO ("
   "    :: A space between '%c >>' writes an extra space at line end"
   "    ECHO %a^>^> ^"
   ")"

:: http://stackoverflow.com/questions/7308586/using-batch-echo-with-special-characters
for /f "useback delims=" %%_ in (%0) do (
  if "%%_"=="___ATAD___" set $=
  if defined $ echo(Test
  if defined $ echo(%%_
  if "%%_"=="___DATA___" set $=1
)
pause
goto :eof

___DATA____
FOR /F "tokens=*" %%a IN ('type %software_all%
<?xml version="1.0" encoding="utf-8" ?>
 <root>
   <data id="1">
      hello world
   </data>
 </root>
ECHO %%a>> %software_in_scope%
___ATAD____

:RUN

:: http://stackoverflow.com/questions/7308586/using-batch-echo-with-special-characters
for /f "useback delims=" %%_ in (%0) do (
  if "%%_"=="___ATAD___" set $=
  if defined $ (
    echo(%%_>> c.txt
  )
  if "%%_"=="___DATA___" set $=1
)
goto :eof

___DATA___
  ::
  :: This is a generated file
  ::

  FOR /F "tokens=*" %%_ IN ('type %1 ^
      ^| findstr /V "Intel" ^
      ^| findstr /V "Microsoft"
      ^| findstr /V "C++" ^
      ^| findstr /V "SQL" ^
      ^| findstr /V "@"' ^
      ) DO (
      ECHO %%_>> %2
  )
___ATAD___


