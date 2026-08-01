@echo off
cd /d C:\dev\Momentum\src\client
flutter test test\g5_yerel_koruma_kapisi_test.dart > C:\dev\Momentum\KANIT\slice-3d\09-MUTANT\_tmp_out.txt 2>&1
exit /b %ERRORLEVEL%
