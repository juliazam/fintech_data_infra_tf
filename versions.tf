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
}