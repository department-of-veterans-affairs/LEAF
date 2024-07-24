#!/bin/bash

# Select Components Ensure Open Git Bash and Open Git Gui
# Configure the line ending conversions Checkout as-is commit as-is

echo "Create docker networks"

docker network create leaf
docker network create leaf-sql

echo "Build external volumes"

docker volume create leaf-php-data
docker volume create leaf-lib

echo "Navigate to LEAF docker directory"

cd docker

echo "Build the docker containers"

docker compose up --build -d
