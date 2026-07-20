terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "test"
  secret_key = "test"

  s3_use_path_style = true

  endpoints {
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
  
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}