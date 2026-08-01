@echo off
cd /d C:\dev\Momentum\src\client
flutter test %1 > %2 2>&1
exit /b %ERRORLEVEL%
