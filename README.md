# PRUEBA TÉCNICA ROL DEVOPS

**Autor:** Miguel Arturo Muñoz Segura

## Descripción del Proyecto
Este proyecto despliega una aplicación web sencilla utilizando infraestructura en AWS gestionada con Terraform. La aplicación consta de un frontend alojado en un bucket de S3, un backend contenerizado en Docker que corre en una instancia EC2 t2.micro, y una base de datos PostgreSQL gestionada por el servicio RDS de AWS. La aplicación permite insertar y obtener registros.

## Arquitectura Utilizada

1. **VPC (Virtual Private Cloud)**
   - **VPC:** Se crea una VPC con un bloque CIDR de 10.0.0.0/16 para aislar la infraestructura de red.

2. **Subredes**
   - **Subred Pública:** Dos subredes públicas en diferentes zonas de disponibilidad (us-east-1a y us-east-1b) para alta disponibilidad.
   - **Subred Privada:** Dos subredes privadas en diferentes zonas de disponibilidad para la base de datos y otros recursos internos.

3. **Internet Gateway y Tabla de Rutas**
   - **Internet Gateway:** Permite la comunicación de las subredes públicas con Internet.
   - **Tabla de Rutas Pública:** Configurada para enrutar el tráfico de las subredes públicas a través del Internet Gateway.

4. **S3**
   - **Bucket S3:** Almacena los archivos estáticos del frontend de la aplicación.

5. **EC2**
   - **Instancia EC2 t2.micro:** Corre el backend contenerizado en Docker. Se eligió t2.micro por su bajo costo y suficiente capacidad para una aplicación sencilla.

6. **RDS**
   - **RDS PostgreSQL:** Base de datos gestionada que proporciona alta disponibilidad y escalabilidad. PostgreSQL fue elegido por su robustez y características avanzadas.

7. **Balanceador de Carga**
   - **ALB:** Distribuye el tráfico entrante entre las instancias EC2 para mejorar la disponibilidad y escalabilidad de la aplicación.
     - **Target Group:** Grupo de destino que incluye la instancia EC2.
     - **Listener:** Configurado para escuchar en el puerto 80 y reenviar el tráfico al grupo de destino.

## Razones para Elegir este Stack

### Costos
- **EC2 t2.micro:** Es una de las instancias más económicas, adecuada para aplicaciones de baja carga.
- **S3:** Ofrece almacenamiento escalable y de bajo costo para archivos estáticos.
- **RDS:** Aunque es más costoso que una base de datos autogestionada, RDS reduce la carga operativa y proporciona backups automáticos, recuperación ante desastres y escalabilidad.
- **ALB:** Proporciona balanceo de carga a un costo razonable, mejorando la disponibilidad sin necesidad de gestionar múltiples instancias manualmente.

### Disponibilidad
- **Multi-AZ:** La utilización de múltiples zonas de disponibilidad para subredes y RDS asegura alta disponibilidad y tolerancia a fallos.
- **S3:** Ofrece alta durabilidad y disponibilidad para los archivos estáticos.
- **ALB:** Mejora la disponibilidad al distribuir el tráfico entre múltiples instancias EC2.

### Escalabilidad
- **S3 y RDS:** Ambos servicios son altamente escalables, permitiendo manejar incrementos en la carga sin necesidad de cambios significativos en la infraestructura.
- **ALB:** Facilita la escalabilidad horizontal al permitir añadir o quitar instancias EC2 según sea necesario.

## Posibles Mejoras
1. **Auto Scaling:** Implementar grupos de autoescalado para la instancia EC2 para manejar incrementos en la carga de trabajo.
2. **CloudFront:** Utilizar Amazon CloudFront para distribuir el contenido del frontend globalmente con baja latencia.
3. **Seguridad:** Implementar políticas de IAM más estrictas y grupos de seguridad para mejorar la seguridad de la infraestructura. Uso de secretos para la información sensible. Por temas de tiempo se dejaron quemadas dentro del código lo cual es una mala práctica.
4. **Monitoreo y Logging:** Configurar CloudWatch para monitorear el rendimiento de la aplicación y registrar eventos importantes.
5. **Backup y Recuperación:** Configurar estrategias de backup y recuperación para la base de datos RDS.
6. **Integración y Despliegue Continuo:** Implementar un flujo de CICD completo utilizando Jenkins para integrar los cambios realizados y para desplegar la solución generando una imagen nueva actualizada. El pipeline se ejecutaría con cada commit hacia el repositorio.