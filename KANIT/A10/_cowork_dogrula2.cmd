@echo off
setlocal enabledelayedexpansion
cd /d C:\dev\Momentum\src\client
set PROGRAMFILES(X86)=C:\Program Files (x86)

echo === COWORK BAGIMSIZ DOGRULAMA 2 -- TEMIZ RELEASE DERLEMESI + APK OLCUMU ===
echo.

echo --- 0) aapt2 SURUMU OLCULUYOR (varsayilmiyor)
for /f "delims=" %%i in ('dir /b /ad "C:\Users\gulci\AppData\Local\Android\Sdk\build-tools"') do set BT=%%i
set AAPT2=C:\Users\gulci\AppData\Local\Android\Sdk\build-tools\!BT!\aapt2.exe
echo BUILD-TOOLS=!BT!
echo AAPT2=!AAPT2!
if exist "!AAPT2!" (echo AAPT2-VAR) else (echo AAPT2-YOK)
echo.

echo --- 1) TEMIZ RELEASE DERLEMESI (mutantlardan sonraki gercek agac)
call C:\src\flutter\bin\flutter.bat build apk --release
echo BUILD-RELEASE-EXIT=%ERRORLEVEL%
echo.

echo --- 2) G17/b  release APK izinleri (pozitif kontrol: cikti bos olmamali)
"!AAPT2!" dump permissions build\app\outputs\flutter-apk\app-release.apk
echo AAPT2-PERM-EXIT=%ERRORLEVEL%
echo.

echo --- 3) G17/a + G18/b  release BIRLESTIRILMIS MANIFEST (yol KESFEDILIYOR)
dir /s /b build\app\intermediates\merged_manifests\release\*AndroidManifest.xml
for /f "delims=" %%m in ('dir /s /b build\app\intermediates\merged_manifests\release\*AndroidManifest.xml') do set MM=%%m
echo MERGED-MANIFEST=!MM!
echo -- pozitif kontrol (package= BULUNMALI):
findstr /c:"package=" "!MM!"
echo POZKONTROL-EXIT=%ERRORLEVEL%
echo -- G17/a (INTERNET BULUNMALI):
findstr /c:"android.permission.INTERNET" "!MM!"
echo G17A-EXIT=%ERRORLEVEL%
echo -- G18/b (networkSecurityConfig BULUNMAMALI):
findstr /c:"networkSecurityConfig" "!MM!"
echo G18B-EXIT=%ERRORLEVEL%
echo.

echo --- 4) G18/d  usesCleartextTraffic hicbir manifeste yazilmamis olmali
findstr /s /i /c:"usesCleartextTraffic" C:\dev\Momentum\src\client\android\*.*
echo G18D-EXIT=%ERRORLEVEL%
echo.

echo --- 5) G18/e  release APK icinde network_security_config ADIYLA aranir
"!AAPT2!" dump resources build\app\outputs\flutter-apk\app-release.apk > "%TEMP%\a10_res.txt" 2>&1
findstr /i /c:"network_security_config" "%TEMP%\a10_res.txt"
echo G18E-ADI-EXIT=%ERRORLEVEL%
echo -- ICERIK bazli kontrol (cleartextTrafficPermitted release'te BULUNMAMALI):
findstr /i /c:"cleartextTrafficPermitted" "%TEMP%\a10_res.txt"
echo G18E-ICERIK-EXIT=%ERRORLEVEL%
echo.

echo === BITTI2 ===
endlocal
