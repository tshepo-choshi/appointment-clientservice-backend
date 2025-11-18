#!/bin/bash
# Shell script to stop the application

echo "Stopping Client Service Application..."

echo "Stopping containers..."
docker stop clientservice-app clientservice-postgres 2>/dev/null

echo "Containers stopped"
echo "Done!"
