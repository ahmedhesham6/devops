# Note: Terraform has nothing to do with the containrization of the application.
# Its used to define all the infrastractre components (Server/Database/Networking)

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.59.0"
        }
    }
}

variable "db_name" {
    default = "mydb"
    type = string
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
    type = string
}

variable "db_instance_class" {
    default = "db.t2.micro"
    type = string
}

variable "db_password" {
    default = "mypassword"
    type = string
}

variable "subnet_cidr" {
    default = "10.0.1.0/24"
    type = string
}

variable "db_username" {
    default = "mydbuser"
    type = string
}

variable "instance_type" {
    default = "t2.micro"
    type = string
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_security_group" "ec2_sg" {
    description = "Allow inbound traffic on port 22"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0",
        ]
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }
    name = "ec2_sg"
    vpc_id = aws_vpc.main.id
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
}

resource "aws_db_subnet_group" "mysql" {
    description = "MySQL subnet group"
    name = "mysql"
    subnet_ids = [
        aws_subnet.main.id,
    ]
}

resource "aws_subnet" "main" {
    availability_zone = "us-west-2a"
    cidr_block = var.subnet_cidr
    vpc_id = aws_vpc.main.id
}

resource "aws_instance" "ec2" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = var.instance_type
    key_name = "my_key"
    subnet_id = aws_subnet.main.id
    vpc_security_group_ids = [
        aws_security_group.ec2_sg.id,
    ]
}

resource "aws_db_instance" "mysql" {
    allocated_storage = 10
    db_name = var.db_name
    db_subnet_group_name = aws_db_subnet_group.mysql.name
    engine = "mysql"
    engine_version = "8.0.20"
    instance_class = var.db_instance_class
    password = var.db_password
    username = var.db_username
    vpc_security_group_ids = [
        aws_security_group.ec2_sg.id,
    ]
}