# ================================================================
# Lab 04 - 2-Tier VPC Architecture with Terraform
# Provider Configuration
# ================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags for all resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = "terraform"
      Lab         = "lab-04-2tier-vpc"
      ManagedBy   = "terraform"
      CreatedDate = timestamp()
    }
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
