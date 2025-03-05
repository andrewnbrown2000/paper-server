terraform { 
  cloud { 
    organization = "andrewnbrown" 
    workspaces { 
      name = "paper_server_infrastructure" 
    } 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "paper-sg"
}

resource "aws_security_group" "paper_sg" {
  name        = var.security_group_name
  description = "Security group for paper server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    prefix_list_ids = [aws_prefix_list.com_amazonaws_us_west_1_ec2_instance.id] #not sure if this will work
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami                    = "ami-0293e1152bc276de0" # Replace with a valid AMI ID for your region
  instance_type          = "t4g.medium"
  vpc_security_group_ids = [aws_security_group.paper_sg.id] # Reference the security group

  tags = {
    Name = "paper_server_from_terraform"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_dns" {
  value = aws_instance.example.public_dns
}