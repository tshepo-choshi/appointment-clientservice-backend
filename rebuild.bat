@echo off
REM Batch script to rebuild and restart the application

echo Rebuilding Client Service Application...

REM Load environment variables from .env file
if exist ".env" (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        set "%%a=%%b"
    )
) else (
    echo Error: .env file not found!
    exit /b 1
)

REM Stop and remove old container
echo Stopping old container...
docker stop clientservice-app 2>nul
docker rm clientservice-app 2>nul

REM Rebuild image
echo Building new image...
docker build -t clientservice-app .

if %errorlevel% equ 0 (
    REM Start new container
    echo Starting new container...
    docker run -d ^
        --name clientservice-app ^
        --network clientservice-network ^
        -e SPRING_DATASOURCE_URL="jdbc:postgresql://clientservice-postgres:5432/clientdb" ^
        -e SPRING_DATASOURCE_USERNAME=%DB_USERNAME% ^
        -e SPRING_DATASOURCE_PASSWORD=%DB_PASSWORD% ^
        -e JWT_SECRET=%JWT_SECRET% ^
        -p 8080:8080 ^
        clientservice-app
    
    if %errorlevel% equ 0 (
        echo.
        echo Application rebuilt and restarted successfully!
        echo Application URL: http://localhost:8080
        echo.
        echo To view logs: docker logs -f clientservice-app
    )
) else (
    echo Build failed!
)

pause
