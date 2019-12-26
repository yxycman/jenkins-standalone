terraform {
  backend "s3" {
    key     = "managed_stack/test-vpc"
  }
}