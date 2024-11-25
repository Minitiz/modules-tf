terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 1.0"
    }
  }
}
