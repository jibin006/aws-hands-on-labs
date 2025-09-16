# AWS Hands-On Labs Collection

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
