terraform {
  backend "s3" {
    bucket         = "dev-a0demo-tf-state"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "dev-a0demo-tf-states-lock"
  }
}