# ================================================================
# Lab 04 - 2-Tier VPC Architecture with Terraform
# Provider Configuration
# ================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.62.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "2tier-vpc-lab"
      Environment = "dev"
    }
  }

  ignore_tags {
    keys = [
      "CreatedDate",
      "Environment",
      "ManagedBy",
      "Owner",
      "Project"
    ]
  }
}


# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current region
data "aws_region" "current" {}

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
