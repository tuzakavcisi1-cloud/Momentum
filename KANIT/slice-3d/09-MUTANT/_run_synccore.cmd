@echo off
cd /d C:\dev\Momentum
dotnet test tests\Momentum.SyncCore.Tests\Momentum.SyncCore.Tests.csproj --filter "FullyQualifiedName~SyncIngestV7Tests" --nologo > C:\dev\Momentum\KANIT\slice-3d\09-MUTANT\_tmp_out.txt 2>&1
exit /b %ERRORLEVEL%
