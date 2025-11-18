@echo off
REM Batch script to start the application with Docker/Podman

echo Starting Client Service Application...

REM Check if .env file exists
if not exist ".env" (
    echo Warning: .env file not found!
    if exist ".env.template" (
        echo Creating .env from template...
        copy ".env.template" ".env"
        echo Please edit .env file and set your JWT_SECRET before continuing.
        pause
    ) else (
        echo Error: .env.template not found!
        exit /b 1
    )
)

REM Load environment variables from .env file
for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
    set "%%a=%%b"
)

echo Setting up with docker...

REM Create network if it doesn't exist
docker network ls --format "{{.Name}}" | findstr /x "clientservice-network" >nul
if errorlevel 1 (
    echo Creating network...
    docker network create clientservice-network
)

REM Check if PostgreSQL is running
docker ps --format "{{.Names}}" | findstr /x "clientservice-postgres" >nul
if errorlevel 1 (
    echo Starting PostgreSQL...
    docker run -d ^
        --name clientservice-postgres ^
        --network clientservice-network ^
        -e POSTGRES_DB=clientdb ^
        -e POSTGRES_USER=%DB_USERNAME% ^
        -e POSTGRES_PASSWORD=%DB_PASSWORD% ^
        -p 5432:5432 ^
        postgres:16-alpine
    
    echo Waiting for PostgreSQL to be ready...
    timeout /t 10 /nobreak >nul
) else (
    echo PostgreSQL already running
)

REM Remove old app container if exists
docker ps -a --format "{{.Names}}" | findstr /x "clientservice-app" >nul
if not errorlevel 1 (
    echo Removing old application container...
    docker stop clientservice-app 2>nul
    docker rm clientservice-app 2>nul
)

REM Build application image
echo Building application image...
docker build -t clientservice-app .

if %errorlevel% equ 0 (
    REM Start application
    echo Starting application...
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
        echo Services started successfully!
        echo Application URL: http://localhost:8080
        echo Database: localhost:5432
        echo.
        echo To view logs: docker logs -f clientservice-app
        echo To stop: docker stop clientservice-app clientservice-postgres
    )
)

pause
