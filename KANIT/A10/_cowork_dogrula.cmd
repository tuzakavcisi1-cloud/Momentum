@echo off
setlocal
cd /d C:\dev\Momentum\src\client
set PROGRAMFILES(X86)=C:\Program Files (x86)
set PYTHONIOENCODING=utf-8

echo === COWORK BAGIMSIZ DOGRULAMA (K26) -- builder beyanina guvenilmez ===
echo.

echo --- 1) ANALYZE
call C:\src\flutter\bin\flutter.bat analyze --fatal-infos
echo ANALYZE-EXIT=%ERRORLEVEL%
echo.

echo --- 2) TEST
call C:\src\flutter\bin\flutter.bat test
echo TEST-EXIT=%ERRORLEVEL%
echo.

echo --- 3) G20/a  define VERILEREK
call C:\src\flutter\bin\flutter.bat test --dart-define=DEV_USER_ID=3f2a1b4c-5d6e-4f70-8112-9a0bcdef1234 test\dev_user_id_define_test.dart
echo G20A-EXIT=%ERRORLEVEL%
echo.

echo --- 4) G20/b  define VERILMEDEN
call C:\src\flutter\bin\flutter.bat test test\dev_user_id_define_test.dart
echo G20B-EXIT=%ERRORLEVEL%
echo.

echo === BITTI ===
endlocal
