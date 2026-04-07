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

module "ecs" {
  source = "./modules/ecs"

  cluster_name = "my-cluster"
  task_name    = "my-task"
  service_name = "my-service"

  image_url = module.ecr.repository_url

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  subnets = module.vpc.subnet_ids
}
