@echo off
cd /d C:\dev\Momentum\src\backend\Momentum.Api
set ConnectionStrings__Momentum=Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=momentum_dev
set ASPNETCORE_URLS=http://127.0.0.1:5298
dotnet run --no-launch-profile > C:\dev\Momentum\KANIT\slice-3d\09-MUTANT\_api_log.txt 2>&1
