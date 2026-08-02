@echo off
setlocal enabledelayedexpansion
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
set "FLUTTER=C:\src\flutter\bin\flutter.bat"
set "KANITDIR=C:\dev\Momentum\KANIT\A11"
cd /d C:\dev\Momentum\src\client
echo [KOSUM] oturum 50 -- A11 kabul, adim 2: flutter test> "%KANITDIR%\02-test.txt"
powershell -NoProfile -Command Get-Date -Format o>> "%KANITDIR%\02-test.txt"
call "%FLUTTER%" test>> "%KANITDIR%\02-test.txt" 2>&1
echo EXIT_TEST=!ERRORLEVEL!>> "%KANITDIR%\02-test.txt"
powershell -NoProfile -Command Get-Content "%KANITDIR%\02-test.txt" -Tail 12
