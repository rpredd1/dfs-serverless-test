terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
  }
  backend "s3" {}
  required_version = "~> 1.10.1"
}

provider "aws" {
  region = "us-east-1"
}
