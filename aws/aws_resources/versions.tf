##Define required terraform and provider version
terraform {
  required_version = ">= 1.1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    zipper = {
      source = "ArthurHlt/zipper"
      version = "0.14.0"
    }
  }
}
