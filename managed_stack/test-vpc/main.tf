provider "aws" {
  region = var.aws_region
}


resource "aws_vpc" "test100" {
  cidr_block = "192.168.100.0/24"

  tags = {
    Name = "test VPC for oliashuk Demo"
  }
}
