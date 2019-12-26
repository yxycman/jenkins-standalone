variable "aws_region" {
  description = "The AWS region in which Service will be created."
  default     = "eu-central-1"
}

variable "vpc_name" {
  description = "The name of the VPC in which all the resources should be deployed"
  type        = string
  default     = "jenkins_vpc"
}

variable "instance_type" {
  description = "The type of instance to run"
  type        = string
  default     = "t2.medium"
}

variable "public_key" {
  description = "The key to access instance via SSH"
  type        = string
}

variable "admin_password" {
  description = "The password for Jenkins admin user"
  type        = string
  default     = "softserve"
}

variable "stack_url" {
  description = "The URL for TF stack code to deploy with Jenkins"
  type        = string
  default     = "https://github.com/yxycman/test100.git"
}
