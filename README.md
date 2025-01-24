# DEVOPS ROLE TECHNICAL TEST

**Author:** Miguel Arturo Muñoz Segura

## Project Description
This project deploys a simple web application using AWS infrastructure managed with Terraform. The application consists of a frontend hosted in an S3 bucket, a Docker-containerized backend running on a t2.micro EC2 instance, and a PostgreSQL database managed by AWS RDS. The application allows users to insert and retrieve records.

## Architecture Used

![Architecture (1)](https://github.com/user-attachments/assets/8473222e-16f7-4d47-af0b-0070312216b1)

1. **VPC (Virtual Private Cloud)**
   - **VPC:** A VPC is created with a CIDR block of 10.0.0.0/16 to isolate the network infrastructure.

2. **Subnets**
   - **Public Subnet:** Two public subnets in different availability zones (us-east-1a and us-east-1b) for high availability.
   - **Private Subnet:** Two private subnets in different availability zones for the database and other internal resources.

3. **Internet Gateway and Route Table**
   - **Internet Gateway:** Enables communication between public subnets and the Internet.
   - **Public Route Table:** Configured to route traffic from public subnets through the Internet Gateway.

4. **S3**
   - **S3 Bucket:** Stores the static files for the application frontend.

5. **EC2**
   - **t2.micro EC2 Instance:** Runs the Docker-containerized backend. t2.micro was chosen for its low cost and sufficient capacity for a simple application.

6. **RDS**
   - **RDS PostgreSQL:** Managed database service that provides high availability and scalability. PostgreSQL was chosen for its robustness and advanced features.

7. **Load Balancer**
   - **ALB:** Distributes incoming traffic among EC2 instances to improve application availability and scalability.
     - **Target Group:** Target group that includes the EC2 instance.
     - **Listener:** Configured to listen on port 80 and forward traffic to the target group.

## Reasons for Choosing This Stack

### Cost
- **t2.micro EC2:** One of the most cost-effective instances, suitable for low-load applications.
- **S3:** Provides scalable and low-cost storage for static files.
- **RDS:** While more expensive than self-managed databases, RDS reduces operational overhead and offers automatic backups, disaster recovery, and scalability.
- **ALB:** Offers load balancing at a reasonable cost, improving availability without the need to manage multiple instances manually.

### Availability
- **Multi-AZ:** Using multiple availability zones for subnets and RDS ensures high availability and fault tolerance.
- **S3:** Provides high durability and availability for static files.
- **ALB:** Enhances availability by distributing traffic among multiple EC2 instances.

### Scalability
- **S3 and RDS:** Both services are highly scalable, enabling handling of increased load without significant infrastructure changes.
- **ALB:** Facilitates horizontal scalability by allowing the addition or removal of EC2 instances as needed.

## Possible Improvements
1. **Auto Scaling:** Implement auto-scaling groups for the EC2 instance to handle workload increases.
2. **CloudFront:** Use Amazon CloudFront to globally distribute frontend content with low latency.
3. **Security:** Implement stricter IAM policies and security groups to enhance infrastructure security. Use secrets for sensitive information. Due to time constraints, credentials were hardcoded, which is a bad practice.
4. **Monitoring and Logging:** Configure CloudWatch to monitor application performance and log important events.
5. **Backup and Recovery:** Set up backup and recovery strategies for the RDS database.
6. **Continuous Integration and Deployment:** Implement a complete CI/CD pipeline using Jenkins to integrate changes and deploy the solution by generating an updated image. The pipeline would run with each commit to the repository.

## AWS Infrastructure Created

### Bucket for Hosting Frontend
![image](https://github.com/user-attachments/assets/2ecf079c-be17-4654-9d17-66b50c4890b3)

### Load Balancer to Receive Requests
![image](https://github.com/user-attachments/assets/7afec8c9-4586-4cdd-81a0-fb218f5cd189)

### EC2 Instance Running the API
![image](https://github.com/user-attachments/assets/85ce7133-2b52-4a6e-a37d-3d45fc9555a5)

### RDS Instance Containing the Database
![image](https://github.com/user-attachments/assets/0d800d9a-69a8-4aed-ac18-23ff540113c4)