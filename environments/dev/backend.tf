terraform {
  backend "s3" {
    bucket = "sergei-aplicacao-infra-segura"
    key    = "dev/infra-segura-dev"
    region = "us-east-1"
  }
}
