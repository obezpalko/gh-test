data "aws_region" "current" {}


data "aws_vpc" "default" {
  default = true
}

output "vpc" {
  value = data.aws_vpc.default.id
}
