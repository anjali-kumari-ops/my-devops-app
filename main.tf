# trigger the input after main push+
provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  public_subnet_1_cidr = "10.0.1.0/24"
  public_subnet_2_cidr = "10.0.2.0/24"

  az_1 = "ap-south-1a"
  az_2 = "ap-south-1b"
}

module "ecr" {
  source = "./modules/ecr"

  repo_name = "my-devops-app"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name = "my-cluster"
  task_name    = "my-task"
  service_name = "aws-learning"

  image_url = "${module.ecr.ecr_repo_url}:latest"   

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  subnets = module.vpc.subnet_ids

  security_groups = [aws_security_group.ecs_sg.id]   
}

terraform {
  backend "s3" {
    bucket         = "s3-anjali"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"

  }
}