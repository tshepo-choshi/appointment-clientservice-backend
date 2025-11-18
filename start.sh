#!/bin/bash
# Shell script to start the application with Docker/Podman

echo "Starting Client Service Application..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Warning: .env file not found!"
    if [ -f ".env.template" ]; then
        echo "Creating .env from template..."
        cp .env.template .env
        echo "Please edit .env file and set your JWT_SECRET before continuing."
        read -p "Press Enter to continue or Ctrl+C to exit..."
    else
        echo "Error: .env.template not found!"
        exit 1
    fi
fi

echo "Setting up with docker..."

# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Create network if it doesn't exist
if ! docker network ls --format "{{.Name}}" | grep -q "^clientservice-network$"; then
    echo "Creating network..."
    docker network create clientservice-network
fi

# Check if PostgreSQL is running
if ! docker ps --format "{{.Names}}" | grep -q "^clientservice-postgres$"; then
    echo "Starting PostgreSQL..."
    docker run -d \
        --name clientservice-postgres \
        --network clientservice-network \
        -e POSTGRES_DB=clientdb \
        -e POSTGRES_USER=${DB_USERNAME:-postgres} \
        -e POSTGRES_PASSWORD=${DB_PASSWORD:-postgres} \
        -p 5432:5432 \
        postgres:16-alpine
    
    echo "Waiting for PostgreSQL to be ready..."
    sleep 10
else
    echo "PostgreSQL already running"
fi

# Remove old app container if exists
if docker ps -a --format "{{.Names}}" | grep -q "^clientservice-app$"; then
    echo "Removing old application container..."
    docker stop clientservice-app 2>/dev/null
    docker rm clientservice-app 2>/dev/null
fi

# Build application image
echo "Building application image..."
docker build -t clientservice-app .

if [ $? -eq 0 ]; then
    # Start application
    echo "Starting application..."
    docker run -d \
        --name clientservice-app \
        --network clientservice-network \
        -e SPRING_DATASOURCE_URL="jdbc:postgresql://clientservice-postgres:5432/clientdb" \
        -e SPRING_DATASOURCE_USERNAME=${DB_USERNAME:-postgres} \
        -e SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD:-postgres} \
        -e JWT_SECRET=${JWT_SECRET} \
        -p 8080:8080 \
        clientservice-app
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "Services started successfully!"
        echo "Application URL: http://localhost:8080"
        echo "Database: localhost:5432"
        echo ""
        echo "To view logs: docker logs -f clientservice-app"
        echo "To stop: docker stop clientservice-app clientservice-postgres"
    fi
fi
