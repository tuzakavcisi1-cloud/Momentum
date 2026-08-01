@echo off
cd /d C:\dev\Momentum\src\client
echo === G1 ===
flutter test test\g1_cekme_yolu_kapisi_test.dart > C:\dev\Momentum\KANIT\slice-3d\01-G1-yalniz-cekme\g1-test-ciktisi.txt 2>&1
echo G1 EXIT=%ERRORLEVEL%
echo === G2 ===
flutter test test\g2_migration_kapisi_test.dart > C:\dev\Momentum\KANIT\slice-3d\02-G2-migration\g2-test-ciktisi.txt 2>&1
echo G2 EXIT=%ERRORLEVEL%
echo === G3 ===
flutter test test\g3_ayristirici_kapisi_test.dart > C:\dev\Momentum\KANIT\slice-3d\03-G3-ayristirici\g3-test-ciktisi.txt 2>&1
echo G3 EXIT=%ERRORLEVEL%
echo === G4 ===
flutter test test\g4_lww_kapisi_test.dart > C:\dev\Momentum\KANIT\slice-3d\04-G4-lww\g4-test-ciktisi.txt 2>&1
echo G4 EXIT=%ERRORLEVEL%
echo === G5 ===
flutter test test\g5_yerel_koruma_kapisi_test.dart > C:\dev\Momentum\KANIT\slice-3d\05-G5-yerel-koruma\g5-test-ciktisi.txt 2>&1
echo G5 EXIT=%ERRORLEVEL%
echo === G6 ===
flutter test test\g6_f2_yakinsama_kapisi_test.dart > C:\dev\Momentum\KANIT\slice-3d\06-G6-f2-yakinsama\g6-test-ciktisi.txt 2>&1
echo G6 EXIT=%ERRORLEVEL%
echo === TUMU BITTI ===
