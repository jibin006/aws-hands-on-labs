# AWS Hands-On Labs Collection
A comprehensive collection of AWS hands-on cloud security and network architecture labs designed to provide practical experience with AWS services and security best practices.

## 📚 Lab Catalog

### 🔐 Identity and Access Management
- **Lab 1: Cross-Account IAM Role and Trust Policy**
  - Create IAM role in Account A and allow Account B to assume it (trust policy)
  - Understanding cross-account access patterns
  - Trust policy mechanics and security implications

- **Lab 2: IAM Policy Security Testing**
  - Write restrictive policy (S3 read-only), then break it with s3:*
  - Demonstrate the impact of wildcard permissions
  - Policy evaluation and permission escalation

### 🔍 Security Monitoring
- **Lab 3: CloudTrail Threat Detection**
  - Use CloudTrail to trace wildcard abuse
  - Log analysis and security event detection
  - Identifying suspicious permission patterns

### 🌐 Virtual Private Cloud (VPC) Architecture
- **Lab 4: Multi-Tier VPC Design**
  - Build 2-tier VPC (web+DB)
  - Public and private subnet configuration
  - Route table and security group setup

- **Lab 5: NAT Gateway Implementation**
  - Add NAT GW for outbound connectivity
  - Private subnet internet access patterns
  - Cost optimization considerations

- **Lab 6: Network Security Controls**
  - Test Security Groups vs NACL
  - Stateful vs stateless filtering comparison
  - Layer 4 security control implementation

### 🔗 Hybrid Connectivity
- **Lab 7: Site-to-Site VPN Setup**
  - Simulate Site-to-Site VPN (AWS <-> on-prem/cloud VM)
  - Customer Gateway configuration
  - VPN tunnel establishment and testing

- **Lab 8: Transit Gateway Architecture**
  - Build TGW with 2 VPCs and test routing
  - Multi-VPC connectivity patterns
  - Route table management

- **Lab 9: Gateway Comparison**
  - Compare with VGW routing table (immutable)
  - TGW vs VGW architecture differences
  - Migration considerations and use cases

## 🎯 Learning Objectives
By completing these labs, you will:
- Master AWS security fundamentals and best practices
- Understand network architecture design principles
- Learn to implement defense-in-depth strategies
- Develop skills in security monitoring and incident response
- Gain hands-on experience with hybrid connectivity

## 🛠️ Prerequisites
- AWS Account with administrative access
- Basic understanding of networking concepts
- Familiarity with command line interface
- Text editor or IDE of your choice

## 📋 Lab Structure
Each lab contains:
- **Objective**: What you'll learn and accomplish
- **Architecture Diagram**: Visual representation of the solution
- **Step-by-Step Instructions**: Detailed implementation guide
- **Code Samples**: Terraform/CloudFormation templates where applicable
- **Verification Steps**: How to test your implementation
- **Cleanup Instructions**: Resource removal to avoid charges
- **Troubleshooting**: Common issues and solutions

## 🚀 Getting Started
1. Clone this repository
2. Choose a lab based on your learning objectives
3. Review prerequisites and architecture diagrams
4. Follow step-by-step instructions
5. Verify your implementation
6. Clean up resources when complete

## 📝 Contributing
Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## 📄 License
This project will be licensed under an appropriate open-source license (to be determined).

## ⚠️ Important Notes
- Always review AWS pricing before deploying resources
- Follow cleanup instructions to avoid unnecessary charges
- Use these labs in non-production environments
- Keep security credentials secure and never commit them to version control

## 📚 Additional Resources
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Security Best Practices](https://aws.amazon.com/security/)
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)

---
**Status: Under Development 🚧**

This repository is actively being developed. Labs will be added progressively. Check back regularly for updates!
