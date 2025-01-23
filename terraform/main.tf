# VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "lab_vpc"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "lab_public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "lab_public_subnet"
  }
}

# PUBLIC SUBNET IN US-EAST-1B
resource "aws_subnet" "lab_public_subnet_2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "lab_public_subnet_2"
  }
}

# Asociar la nueva subnet pública al Route Table público
resource "aws_route_table_association" "public_subnet_assoc_2" {
  subnet_id      = aws_subnet.lab_public_subnet_2.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# PRIVATE SUBNET
resource "aws_subnet" "lab_private_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name = "lab_private_subnet"
  }
}

# PRIVATE SUBNET IN US-EAST-1B
resource "aws_subnet" "lab_private_subnet_2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "lab_private_subnet_2"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id
  tags = {
    Name = "lab_igw"
  }
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }
  tags = {
    Name = "lab_public_rt"
  }
}

# ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNET
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.lab_public_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# NAT GATEWAY
resource "aws_nat_gateway" "lab_nat_gw" {
  allocation_id = aws_eip.lab_nat_eip.id
  subnet_id     = aws_subnet.lab_public_subnet.id
  tags = {
    Name = "lab_nat_gw"
  }
}

# ELASTIC IP FOR NAT GATEWAY
resource "aws_eip" "lab_nat_eip" {
  depends_on = [aws_internet_gateway.lab_igw]
}

# PRIVATE ROUTE TABLE
resource "aws_route_table" "lab_private_rt" {
  vpc_id = aws_vpc.lab_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab_nat_gw.id
  }
  tags = {
    Name = "lab_private_rt"
  }
}

# ROUTE TABLE ASSOCIATION FOR PRIVATE SUBNET
resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.lab_private_subnet.id
  route_table_id = aws_route_table.lab_private_rt.id
}

# SECURITY GROUP FOR EC2 INSTANCE
resource "aws_security_group" "todo-app-sg" {
  name        = "todo-app-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todo-app-sg"
  }
}

# SECURITY GROUP FOR LOAD BALANCER
resource "aws_security_group" "elb-sg" {
  name        = "elb-sg"
  description = "Allow HTTP traffic to the Load Balancer"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg"
  }
}

# TARGET GROUP
resource "aws_lb_target_group" "todo-app-tg" {
  name        = "todo-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab_vpc.id
  target_type = "instance"
}

# LOAD BALANCER
resource "aws_lb" "todo-app-lb" {
  name               = "todo-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets = [
    aws_subnet.lab_public_subnet.id,  # us-east-1a
    aws_subnet.lab_public_subnet_2.id # us-east-1b
  ]
  enable_deletion_protection = false

  tags = {
    Name = "todo-app-lb"
  }
}

# LISTENER
resource "aws_lb_listener" "todo-app-listener" {
  load_balancer_arn = aws_lb.todo-app-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo-app-tg.arn
  }
}

# TARGET GROUP ATTACHMENT
resource "aws_lb_target_group_attachment" "todo-app-tg-attachment" {
  target_group_arn = aws_lb_target_group.todo-app-tg.arn
  target_id        = aws_instance.todo-app.id
  port             = 80
}

# SECURITY GROUP FOR RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow EC2 instance access to RDS"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = []
    security_groups = [
      aws_security_group.todo-app-sg.id # Permitir tráfico desde el SG de la EC2
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# EC2 INSTANCE
resource "aws_instance" "todo-app" {
  ami                         = var.ec2_ami
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.lab_public_subnet.id
  key_name                    = "todo-kp"
  vpc_security_group_ids      = [aws_security_group.todo-app-sg.id]

  user_data = <<-EOF
                  #!/bin/bash
                  sudo apt-get update -y
                  sudo apt-get upgrade -y
                  sudo apt-get install -y nodejs npm
                EOF

  root_block_device {
    delete_on_termination = true
    volume_size           = 10
    volume_type           = "gp2"
  }

  tags = {
    Name = "todoApp-Instance"
  }
}

# RDS INSTANCE
resource "aws_db_instance" "postgresql" {
  identifier                = var.db_instance_identifier
  allocated_storage         = 10
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "12"
  instance_class            = "db.t3.micro"
  username                  = var.db_username
  password                  = var.db_password
  parameter_group_name      = "default.postgres12"
  publicly_accessible       = false
  db_subnet_group_name      = aws_db_subnet_group.postgresql_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  final_snapshot_identifier = "notes-db-snapshot"

  tags = {
    Name = "PostgreSQL-DB"
  }
}

# DB SUBNET GROUP
resource "aws_db_subnet_group" "postgresql_subnet_group" {
  name = "postgresql-subnet-group"
  subnet_ids = [
    aws_subnet.lab_private_subnet.id,
    aws_subnet.lab_private_subnet_2.id
  ]
  tags = {
    Name = "postgresql-subnet-group"
  }
}

# S3
resource "aws_s3_bucket" "my_bucket" {
  bucket = "www.${var.s3_bucket_name}"
}
data "aws_s3_bucket" "selected-bucket" {
  bucket = aws_s3_bucket.my_bucket.bucket
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket     = data.aws_s3_bucket.selected-bucket.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = data.aws_s3_bucket.selected-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = data.aws_s3_bucket.selected-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = data.aws_s3_bucket.selected-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = data.aws_s3_bucket.selected-bucket.id
  policy = data.aws_iam_policy_document.iam-policy-1.json
}

data "aws_iam_policy_document" "iam-policy-1" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::www.${var.s3_bucket_name}",
      "arn:aws:s3:::www.${var.s3_bucket_name}/*",
    ]
    actions = ["S3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = data.aws_s3_bucket.selected-bucket.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.jpeg"
  }
}
