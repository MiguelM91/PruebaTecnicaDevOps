
variable "aws_region" {
  default = "us-east-1"
}

variable "subnet_availability_zone_1" {
  default = "us-east-1a"
}


variable "subnet_availability_zone_2" {
  default = "us-east-1b"
}

variable "s3_bucket_name" {
  default = "front-end-storage"
}


variable "tags" {
  default = {
    "Name" = "TODO-app"
  }
}

variable "db_instance_identifier" {
  default = "todo-db-instance"
}

variable "db_username" {
  default = "miguel"
}

variable "db_password" {
  default = "adm1n123*$"
}

variable "ec2_ami" {
  default = "ami-04b4f1a9cf54c11d0"
}
