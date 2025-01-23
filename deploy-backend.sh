# Comando para compilar el backend
docker build \
          --build-arg RDS_INSTANCE_IDENTIFIER=todo-db-instance \
          --build-arg RDS_DB_NAME=todo_db \
          --build-arg RDS_USERNAME=miguel \
          --build-arg RDS_PASSWORD=adm1n123*$ \
          --build-arg S3_BUCKET_NAME=front-end-storage \
          -t todo-app .