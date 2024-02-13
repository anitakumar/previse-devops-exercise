terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=0.14.0"
    }
  }
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}


