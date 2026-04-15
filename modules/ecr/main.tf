# from ECR Delete my-devops-app
resource "aws_ecr_repository" "app" {
  name = "my-devops-app"
}