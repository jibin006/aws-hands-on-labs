# ================================================================
# Lab 04 - 2-Tier VPC Architecture with Terraform
# Variables Configuration
# ================================================================

# ================================================================
# Project & Environment Variables
# ================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "2tier-vpc-lab"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# ================================================================
# AWS Configuration Variables
# ================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# ================================================================
# VPC Configuration Variables
# ================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

# ================================================================
# Subnet Configuration Variables
# ================================================================

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnet CIDRs are required for high availability."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least 2 private subnet CIDRs are required for high availability."
  }
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch for public subnets"
  type        = bool
  default     = true
}

# ================================================================
# NAT Gateway Configuration
# ================================================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single shared NAT Gateway across all private subnets"
  type        = bool
  default     = false
}

# ================================================================
# EC2 Configuration Variables
# ================================================================

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  default     = ""
  
  validation {
    condition     = length(var.key_pair_name) > 0
    error_message = "Key pair name is required for EC2 instances."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "t3.large"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, t3.medium, or t3.large."
  }
}

variable "web_instance_count" {
  description = "Number of web instances to create"
  type        = number
  default     = 2
  
  validation {
    condition     = var.web_instance_count >= 1 && var.web_instance_count <= 10
    error_message = "Web instance count must be between 1 and 10."
  }
}

variable "db_instance_count" {
  description = "Number of database instances to create"
  type        = number
  default     = 2
  
  validation {
    condition     = var.db_instance_count >= 1 && var.db_instance_count <= 10
    error_message = "Database instance count must be between 1 and 10."
  }
}

# ================================================================
# Security Configuration Variables
# ================================================================

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to instances"
  type        = string
  default     = "0.0.0.0/0"
  
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "Allowed SSH CIDR must be a valid IPv4 CIDR block."
  }
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access HTTP services"
  type        = string
  default     = "0.0.0.0/0"
  
  validation {
    condition     = can(cidrhost(var.allowed_http_cidr, 0))
    error_message = "Allowed HTTP CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

# ================================================================
# Monitoring & Logging Variables
# ================================================================

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 1 and 35."
  }
}

# ================================================================
# Local Variables for Advanced Configuration
# ================================================================

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = "terraform"
    Lab         = "lab-04-2tier-vpc"
  }
  
  # Generate AZ names based on region
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  
  # Create subnet configurations
  public_subnets = [
    for i, cidr in var.public_subnet_cidrs : {
      cidr = cidr
      az   = local.azs[i % length(local.azs)]
      name = "${var.project_name}-public-${i + 1}"
    }
  ]
  
  private_subnets = [
    for i, cidr in var.private_subnet_cidrs : {
      cidr = cidr
      az   = local.azs[i % length(local.azs)]
      name = "${var.project_name}-private-${i + 1}"
    }
  ]
}

# ================================================================
# Validation: Ensure subnets are within VPC CIDR
# ================================================================

# Note: These validations would be implemented as data sources or 
# custom validation functions in a production environment
