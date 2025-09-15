# Lab 04 - 2-Tier VPC Architecture with Terraform

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Folder Structure](#folder-structure)
- [Lab Steps](#lab-steps)
- [Post-Deployment Testing](#post-deployment-testing)
- [Clean Up](#clean-up)
- [Additional Resources](#additional-resources)

## Overview

This lab demonstrates how to create a secure 2-tier VPC architecture on AWS using Terraform. The architecture includes:

- **Public Tier**: Web servers in public subnets with Internet Gateway access
- **Private Tier**: Database/application servers in private subnets with NAT Gateway for outbound access
- **Security**: Properly configured security groups, NACLs, and route tables
- **High Availability**: Resources distributed across multiple Availability Zones

## Architecture

The lab creates the following AWS resources:

```
┌─────────────────────────────────────────────────────────────────┐
│                           VPC (10.0.0.0/16)                    │
│                                                                 │
│  ┌─────────────────────┐           ┌─────────────────────┐      │
│  │   Public Subnet     │           │   Public Subnet     │      │
│  │   (10.0.1.0/24)     │           │   (10.0.2.0/24)     │      │
│  │   AZ-1              │           │   AZ-2              │      │
│  │  ┌─────────────┐    │           │  ┌─────────────┐    │      │
│  │  │Web Instance │    │           │  │Web Instance │    │      │
│  │  │             │    │           │  │             │    │      │
│  │  └─────────────┘    │           │  └─────────────┘    │      │
│  └─────────────────────┘           └─────────────────────┘      │
│           │                                 │                   │
│           └─────────────────┬───────────────┘                   │
│                             │                                   │
│  ┌─────────────────────┐   ┌┴┐   ┌─────────────────────┐      │
│  │   Private Subnet    │   │ │   │   Private Subnet    │      │
│  │   (10.0.3.0/24)     │   │IGW  │   (10.0.4.0/24)     │      │
│  │   AZ-1              │   │ │   │   AZ-2              │      │
│  │  ┌─────────────┐    │   └─┘   │  ┌─────────────┐    │      │
│  │  │DB Instance  │    │         │  │DB Instance  │    │      │
│  │  │             │    │         │  │             │    │      │
│  │  └─────────────┘    │         │  └─────────────┘    │      │
│  └─────────────────────┘         └─────────────────────┘      │
│           │                               │                   │
│       ┌───┴────┐                     ┌────┴───┐               │
│       │NAT-GW-1│                     │NAT-GW-2│               │
│       └────────┘                     └────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- AWS CLI installed and configured with appropriate permissions
- Terraform >= 1.0 installed
- An AWS account with programmatic access
- Basic understanding of VPC concepts
- SSH key pair for EC2 instance access

### Required AWS Permissions

Ensure your AWS credentials have the following permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "iam:ListInstanceProfiles",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
```

## Folder Structure

Create the following folder structure for this lab:

```
lab-04-2tier-vpc/
├── README.md
├── provider.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
└── scripts/
    └── userdata.sh
```

## Lab Steps

### Step 1: Clone and Setup

```bash
# Clone the repository
git clone https://github.com/jibin006/cloudsec-labs.git
cd cloudsec-labs/lab-04-2tier-vpc

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### Step 2: Configure Variables

Edit `terraform.tfvars` and set your preferred values:
```hcl
aws_region = "us-west-2"
project_name = "2tier-vpc-lab"
environment = "dev"
key_pair_name = "your-key-pair-name"
allowed_ssh_cidr = "your-ip/32"
```

### Step 3: Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code (optional)
terraform fmt
```

### Step 4: Plan Infrastructure

```bash
# Review the execution plan
terraform plan

# Save plan to file (optional)
terraform plan -out=tfplan
```

### Step 5: Apply Configuration

```bash
# Apply the configuration
terraform apply

# Or apply from saved plan
terraform apply tfplan
```

Type `yes` when prompted to confirm the apply.

### Step 6: Verify Deployment

After successful deployment, Terraform will output key information:
- VPC ID
- Subnet IDs
- Instance IDs and Public IPs
- Security Group IDs


## Mistakes i made while doing this lab:

summarizes the common issues encountered while building a 2-tier VPC infrastructure with Terraform and their solutions.

## Issues Encountered & Solutions

### 1. **Incorrect Attribute Value Type - CIDR Block**
**Error:**
```
Error: Incorrect attribute value type
cidr_block = var.public_subnet_cidrs
var.public_subnet_cidrs is a list of string
Inappropriate value for attribute "cidr_block": string required.
```

**Problem:** Trying to assign a list/array to `cidr_block` which expects a single string value.

**Fix:** 
- Use `for_each` to iterate over the list, OR
- Change variable from list to single string:
```hcl
variable "public_subnet_cidr" {
  default = "10.0.1.0/24"  # string, not ["10.0.1.0/24"]
}
```

### 2. **Invalid CIDR Block - Placeholder Values**
**Error:**
```
Error: "YOUR_IP/32" is not a valid CIDR block: invalid CIDR address: YOUR_IP/32
```

**Problem:** Left placeholder values in security group CIDR blocks.

**Fix:** Replace placeholders with actual IP addresses:
```hcl
variable "my_ip" {
  default = "203.0.113.25/32"  # Your actual public IP
}
```

### 3. **Duplicate Resource Configuration**
**Error:**
```
Error: Duplicate resource "aws_subnet" configuration
A aws_subnet resource named "public" was already declared at main.tf:8,1-31
```

**Problem:** Same resource defined in multiple files (main.tf and variables.tf).

**Fix:** Keep resources only in `main.tf`, variables only in `variables.tf`.

### 4. **Missing Resource Instance Key**
**Error:**
```
Error: Missing resource instance key
Because aws_subnet.public has "for_each" set, its attributes must be accessed on specific instances.
```

**Problem:** Using `for_each` but referencing resource without specifying which instance.

**Fix:** Either remove `for_each` for single resources or reference specific instances:
```hcl
# Option 1: Single resource (recommended for 2-tier VPC)
resource "aws_subnet" "public" {
  cidr_block = var.public_subnet_cidr  # No for_each
}

# Option 2: Multiple resources with specific reference
subnet_id = values(aws_subnet.public)[0].id
```

### 5. **Each.value in Wrong Context**
**Error:**
```
Error: each.value cannot be used in this context
cidr_block = each.value
```

**Problem:** Using `each.value` without `for_each` declaration.

**Fix:** Either add `for_each` or replace with variable reference:
```hcl
cidr_block = var.public_subnet_cidr  # Not each.value
```

### 6. **Variable Type Mismatch**
**Error:**
```
Error: Incorrect attribute value type
var.public_subnet_cidr is tuple with 1 element
```

**Problem:** Variable defined as list but used as string.

**Fix:** Correct variable definition:
```hcl
variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
```

### 7. **Iteration Over Non-iterable Value**
**Error:**
```
Error: Iteration over non-iterable value
for i, cidr in var.public_subnet_cidr
A value of type string cannot be used as the collection in a 'for' expression.
```

**Problem:** Using `for` loop on string variable instead of list.

**Fix:** Either change variable to list or remove the `for` expression:
```hcl
# For single subnet (recommended)
locals {
  public_subnets = [{
    cidr = var.public_subnet_cidr
    az   = "us-east-1a"
    name = "public-1"
  }]
}
```

### 8. **Duplicate Local Value Definition**
**Error:**
```
Error: Duplicate local value definition
A local value named "public_subnets" was already defined at locals.tf:2,3-8,4
```

**Problem:** Same local value defined in multiple files.

**Fix:** Keep all locals in `locals.tf` only, remove duplicates from other files.

### 9. **Reference to Undeclared Local Value**
**Error:**
```
Error: Reference to undeclared local value
A local value with the name "azs" has not been declared.
```

**Problem:** Using `local.azs` without defining it.

**Fix:** Define the availability zones:
```hcl
locals {
  azs = ["us-east-1a", "us-east-1b"]
}
```

### 10. **Provider Inconsistent Final Plan - Tags**
**Error:**
```
Error: Provider produced inconsistent final plan
new element "CreatedDate" has appeared.
This is a bug in the provider, which should be reported in the provider's own issue tracker.
```

**Problem:** AWS provider merging default tags with resource tags, causing state inconsistency.

**Fix:** Add lifecycle rule to ignore tag changes:
```hcl
resource "aws_vpc" "main" {
  # ... other configuration
  
  lifecycle {
    ignore_changes = [tags_all]
  }
}
```

### 11. **Invalid Availability Zone**
**Error:**
```
Error: InvalidParameterValue: Value (us-east-1a) for parameter availabilityZone is invalid.
Subnets can currently only be created in: us-west-2a, us-west-2b, us-west-2c, us-west-2d.
```

**Problem:** Provider region doesn't match availability zone specified in resources.

**Fix:** Ensure region and AZ alignment:
```hcl
provider "aws" {
  region = "us-east-1"  # Match your AZ region
}
```

### 12. **Incorrect EIP Domain Value**
**Error:**
```
Error: expected domain to be one of ["vpc" "standard"], got true
```

**Problem:** Using boolean `true` instead of string value for EIP domain.

**Fix:**
```hcl
resource "aws_eip" "nat_eip" {
  domain = "vpc"  # Not domain = true
}
```

### 13. **Invalid AMI ID**
**Error:**
```
Error: InvalidAMIID.NotFound: The image id '[ami-12345678]' does not exist
```

**Problem:** Using non-existent or region-specific AMI ID.

**Fix:** Use dynamic AMI lookup:
```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
}
```

### 14. **Invalid Subnet ID**
**Error:**
```
Error: InvalidSubnetID.NotFound: The subnet ID 'subnet-04330ff99efb20c99' does not exist
```

**Problem:** Hardcoded subnet IDs that don't exist or stale state.

**Fix:** Reference Terraform-managed subnets:
```hcl
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id  # Reference, not hardcoded ID
}
```

### 15. **CIDR Conflict**
**Error:**
```
Error: InvalidSubnet.Conflict: The CIDR '10.0.1.0/24' conflicts with another subnet
```

**Problem:** Subnet CIDR overlaps with existing subnets in the VPC.

**Fix:** Use non-conflicting CIDR ranges:
```hcl
variable "public_subnet_cidr"  { default = "10.0.10.0/24" }
variable "private_subnet_cidr" { default = "10.0.20.0/24" }
```

## Key Lessons Learned

1. **File Organization:** Keep resources in `main.tf`, variables in `variables.tf`, locals in `locals.tf`
2. **Variable Types:** Be explicit about `string` vs `list(string)` in variable definitions
3. **Resource References:** Use Terraform resource references (`aws_subnet.public.id`) instead of hardcoded IDs
4. **Regional Consistency:** Ensure provider region matches availability zones and AMI availability
5. **Tag Management:** Use `lifecycle { ignore_changes = [tags_all] }` to handle AWS auto-tagging
6. **Dynamic Resources:** Use data sources for AMIs and other region-specific resources

## Best Practices Applied

- Use dynamic AMI lookup instead of hardcoded AMI IDs
- Reference Terraform-managed resources instead of hardcoding AWS resource IDs  
- Implement proper lifecycle management for tags
- Maintain clear separation between variables, locals, and resources
- Use meaningful resource names and consistent naming conventions

## Post-Deployment Testing

### Test 1: Connectivity Testing

```bash
# Get the web instance public IPs from Terraform output
terraform output web_instance_public_ips

# SSH to web instances (should work)
ssh -i ~/.ssh/your-key.pem ec2-user@<web-instance-public-ip>

# Test internet connectivity from web instance
curl -I http://google.com
```

### Test 2: Private Instance Connectivity

```bash
# From web instance, SSH to private instance
ssh -i ~/.ssh/your-key.pem ec2-user@<private-instance-private-ip>

# Test outbound internet access through NAT (should work)
curl -I http://google.com

# Verify no direct internet access (check no public IP)
ip addr show
```

### Test 3: Security Group Testing

```bash
# Test web security group (port 80 should be open)
curl http://<web-instance-public-ip>

# Test SSH access restriction
nmap -p 22 <web-instance-public-ip>

# Test private instance isolation
nmap -p 22 <private-instance-private-ip> # Should timeout from internet
```

### Test 4: Network ACL Testing

```bash
# Check NACL rules
aws ec2 describe-network-acls --filters "Name=vpc-id,Values=<vpc-id>"

# Test allowed traffic
telnet <private-instance-ip> 3306

# Test blocked traffic (should fail)
telnet <private-instance-ip> 23
```

### Test 5: Route Table Verification

```bash
# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"

# Verify public subnet routes to IGW
# Verify private subnet routes to NAT Gateway
```

## Clean Up

⚠️ **Important**: Always clean up resources to avoid ongoing AWS charges.

### Option 1: Terraform Destroy (Recommended)

```bash
# Destroy all resources
terraform destroy

# Review what will be destroyed and type 'yes' to confirm
```

### Option 2: Manual Cleanup (if Terraform fails)

If `terraform destroy` fails, manually delete resources in this order:

1. **EC2 Instances**
   ```bash
   aws ec2 terminate-instances --instance-ids <instance-id-1> <instance-id-2>
   ```

2. **NAT Gateways**
   ```bash
   aws ec2 delete-nat-gateway --nat-gateway-id <nat-gateway-id>
   ```

3. **Internet Gateway**
   ```bash
   aws ec2 detach-internet-gateway --internet-gateway-id <igw-id> --vpc-id <vpc-id>
   aws ec2 delete-internet-gateway --internet-gateway-id <igw-id>
   ```

4. **Subnets**
   ```bash
   aws ec2 delete-subnet --subnet-id <subnet-id>
   ```

5. **Security Groups**
   ```bash
   aws ec2 delete-security-group --group-id <security-group-id>
   ```

6. **VPC**
   ```bash
   aws ec2 delete-vpc --vpc-id <vpc-id>
   ```

### Cleanup Verification

```bash
# Verify all resources are deleted
terraform show

# Check for any remaining resources
aws ec2 describe-instances --filters "Name=tag:Project,Values=2tier-vpc-lab"
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=2tier-vpc-lab"
```

## Additional Resources

### Terraform Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### AWS Documentation
- [VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)
- [NAT Gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)

### Security Best Practices
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [VPC Security](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform Security](https://learn.hashicorp.com/tutorials/terraform/sensitive-variables)

### Troubleshooting

#### Common Issues

1. **Terraform Init Fails**
   ```bash
   # Clear Terraform cache
   rm -rf .terraform
   terraform init
   ```

2. **AWS Credentials Issues**
   ```bash
   # Verify AWS credentials
   aws sts get-caller-identity
   aws configure list
   ```

3. **Resource Limits**
   - Check VPC limits in your region
   - Verify Elastic IP limits
   - Check EC2 instance limits

4. **Destroy Issues**
   ```bash
   # Force refresh state
   terraform refresh
   
   # Target specific resources
   terraform destroy -target=aws_instance.web
   ```

---

**Lab Duration**: Approximately 45-60 minutes  
**Difficulty Level**: Intermediate  
**Cost Estimate**: ~$1-2 per hour (remember to clean up!)
