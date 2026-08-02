@echo off
setlocal enabledelayedexpansion
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
set "FLUTTER=C:\src\flutter\bin\flutter.bat"
set "KANITDIR=C:\dev\Momentum\KANIT\A11"
cd /d C:\dev\Momentum\src\client
echo [KOSUM] oturum 50 -- A11 kabul, adim 1: flutter analyze --fatal-infos> "%KANITDIR%\01-analyze.txt"
powershell -NoProfile -Command Get-Date -Format o>> "%KANITDIR%\01-analyze.txt"
call "%FLUTTER%" analyze --fatal-infos>> "%KANITDIR%\01-analyze.txt" 2>&1
echo EXIT_ANALYZE=!ERRORLEVEL!>> "%KANITDIR%\01-analyze.txt"
type "%KANITDIR%\01-analyze.txt"
