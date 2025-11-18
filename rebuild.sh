#!/bin/bash
# Shell script to rebuild and restart the application

echo "Rebuilding Client Service Application..."

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

# Stop and remove old container
echo "Stopping old container..."
docker stop clientservice-app 2>/dev/null
docker rm clientservice-app 2>/dev/null

# Rebuild image
echo "Building new image..."
docker build -t clientservice-app .

if [ $? -eq 0 ]; then
    # Start new container
    echo "Starting new container..."
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
        echo "Application rebuilt and restarted successfully!"
        echo "Application URL: http://localhost:8080"
        echo ""
        echo "To view logs: docker logs -f clientservice-app"
    fi
else
    echo "Build failed!"
    exit 1
fi
