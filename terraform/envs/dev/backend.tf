terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "ap-northeast-1"
    bucket  = "a0demo-dev-terraform-states"
    key     = "terraform.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "a0demo-dev-terraform-states-lock"
  }
}
