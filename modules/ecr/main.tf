# ecr trigger
resource "aws_ecr_repository" "app" {
  name = "my-devops-app"
}