variable "cluster_name" {}
variable "task_name" {}
variable "service_name" {}

variable "image_url" {}
variable "execution_role_arn" {}

variable "subnets" {
  type = list(string)
}
