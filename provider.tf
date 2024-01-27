terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.33.0"
    }
  }
  backend "s3" {
    bucket = "roboshop-locking" 
    key = "eks-terraform" 
    region = "us-east-1"
    dynamodb_table = "roboshop-state-lock" 
  }
}

provider "aws" {
  region = "us-east-1" 
}

