terraform {
  backend "s3" {
    bucket = "sergei-aplicacao-infraestrutura-segura"
    key    = "projeto"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

# Configure the AWS Provider
provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}