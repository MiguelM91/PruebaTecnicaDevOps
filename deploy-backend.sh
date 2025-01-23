# Comando para compilar el backend
docker build \
          --build-arg RDS_INSTANCE_IDENTIFIER=todo-db-instance \
          --build-arg RDS_DB_NAME=todo_db \
          --build-arg RDS_USERNAME=miguel \
          --build-arg RDS_PASSWORD=adm1n123*$ \
          --build-arg S3_BUCKET_NAME=front-end-storage \
          -t todo-app .

# Comando para correr el backend

docker rm -f todo-app-container

docker run -d -p 5000:5000 \
          --name todo-app-container \
          -e RDS_INSTANCE_IDENTIFIER=todo-db-instance \
          -e RDS_DB_NAME=todo_db \
          -e RDS_USERNAME=miguel \
          -e RDS_PASSWORD=adm1n123*$ \
          -e S3_BUCKET_NAME=front-end-storage \
          todo-app