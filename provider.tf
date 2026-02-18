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
  region = "us-east-1"

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Owner       = "Sergei"
      Project     = "infraestrutura-segura"
      Environment = "Dev"
    }
  }
}