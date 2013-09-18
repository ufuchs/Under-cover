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

:: http://stackoverflow.com/questions/7308586/using-batch-echo-with-special-characters
for /f "useback delims=" %%_ in (%0) do (
  if "%%_"=="___ATAD___" set $=
  if defined $ echo(%%_
  if "%%_"=="___DATA___" set $=1
)
pause
goto :eof

___DATA____
<?xml version="1.0" encoding="utf-8" ?>
 <root>
   <data id="1">
      hello world
   </data>
 </root>
___ATAD____



__WSH_SCRIPT__

WScript.StdOut.Write "  Download " 
dim http: set http = createobject("WinHttp.WinHttpRequest.5.1")
dim bStrm: set bStrm = createobject("Adodb.Stream")
http.Open "GET", %nodejsUrl%, True
http.Send
while http.WaitForResponse(0) = 0
    WScript.StdOut.Write "."
    WScript.Sleep 1000
wend
WScript.StdOut.WriteLine " [HTTP " ^& http.Status ^& " " ^& http.StatusText ^& "]"
WScript.StdOut.Write "  "
with bStrm
    .type = 1 '//binary
    .open
    .write http.responseBody
    .savetofile "%TEMP%\%nodejsMsiPackage%", 2
end with

__TPIRCS_HSW__

:RUN




 