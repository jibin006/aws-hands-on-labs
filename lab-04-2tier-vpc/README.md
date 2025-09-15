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
