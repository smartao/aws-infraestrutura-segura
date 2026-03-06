terraform {
  backend "s3" {
    bucket = "sergei-aplicacao-infraestrutura-segura"
    key    = "dev/infra-segura-dev"
    region = "us-east-1"
  }
}