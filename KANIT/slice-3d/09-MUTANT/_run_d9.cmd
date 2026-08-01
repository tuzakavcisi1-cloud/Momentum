@echo off
cd /d C:\dev\Momentum
set MOMENTUM_KANIT_DIZIN=C:\dev\Momentum\KANIT\slice-3d\09-MUTANT\_tmp_d9_kanit
if not exist "%MOMENTUM_KANIT_DIZIN%" mkdir "%MOMENTUM_KANIT_DIZIN%"
dotnet test tests\Momentum.Persistence.Tests\Momentum.Persistence.Tests.csproj --filter "FullyQualifiedName~D9OwnerIdVisibilityTests" --nologo > C:\dev\Momentum\KANIT\slice-3d\09-MUTANT\_tmp_out.txt 2>&1
exit /b %ERRORLEVEL%
