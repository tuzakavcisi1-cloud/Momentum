@echo off
cd /d C:\dev\Momentum\src\client
flutter test tool\f3_iki_istemci_yakinsama.dart > C:\dev\Momentum\KANIT\slice-3d\08-G8-f3-canli\g8-test-ciktisi.txt 2>&1
exit /b %ERRORLEVEL%
