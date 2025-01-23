#!/bin/bash

# Comando para compilar el backend
docker build \
          --build-arg RDS_DB_HOST=todo-db-instance.cydtm00m8zc1.us-east-1.rds.amazonaws.com \
          --build-arg RDS_DB_NAME=todos \
          --build-arg RDS_DB_USERNAME=miguel \
          --build-arg RDS_PASSWORD=adm1n123*$ \
          --build-arg S3_BUCKET_NAME=front-end-storage \
          --build-arg RDS_DB_PORT=5432 \
          -t todo-app .

# Comando para correr el backend

docker rm -f todo-app-container

docker run -d -p 5000:5000 \
          --name todo-app-container \
          -e RDS_DB_HOST=todo-db-instance.cydtm00m8zc1.us-east-1.rds.amazonaws.com \
          -e RDS_DB_NAME=todos \
          -e RDS_DB_USERNAME=miguel \
          -e RDS_DB_PASSWORD=adm1n123*$ \
          -e RDS_DB_PORT=5432 \
          -e S3_BUCKET_NAME=front-end-storage \
          todo-app