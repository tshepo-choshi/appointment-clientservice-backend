@echo off
REM Batch script to stop the application

echo Stopping Client Service Application...

echo Stopping containers...
docker stop clientservice-app clientservice-postgres 2>nul

echo Containers stopped
echo Done!

pause
