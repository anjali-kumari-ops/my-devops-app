# ecsTaskExecutionRole deleted from IAM role
resource "aws_ecr_repository" "app" {
  name = "my-devops-app"
}