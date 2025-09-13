# Lab 01: Cross-Account IAM Role S3 Access

## Objective
Enable Account A to securely access an S3 bucket in Account B via an IAM role and trust policy.

## Scenario
- Account A (data team) must access `bucket_name` in Account B.
- Achieved by creating a cross-account IAM role in Account B that Account A can assume.

## Architecture Diagram

```mermaid
flowchart LR
    subgraph AccountA["Account A"]
        A1[IAM User / Role]
    end

    subgraph AccountB["Account B"]
        B1[Cross-Account IAM Role: S3Consumer]
        B2[(S3 Bucket)]
    end

    A1 -- "sts:AssumeRole" --> B1
    B1 -- "AmazonS3ReadOnlyAccess" --> B2


```

## Usage

### 1. Edit Variables
Adjust `variables.tf` values if your **Account IDs** or **S3 bucket name** differ from defaults.

---

### 2. Deploy
For separate AWS accounts/profiles, configure your **Terraform CLI** or **AWS credentials** accordingly:

```bash
terraform init
terraform plan
terraform apply
```
### 3. Test
From Account A, assume the role in Account B:

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::<AccountB_ID>:role/CrossAccountS3Access \
  --role-session-name test-session \
  --profile account_a
```
Use the returned temporary credentials to test S3 operations, for example:

```bash
aws s3 ls s3://<bucket_name> \
  --profile account_a
```
### 4. Cleanup
Tear down resources when finished:

```bash
terraform destroy
```

## AWS Cross-Account S3 Lab - Mistakes and Fixes Summary

## 1. AWS CLI Command Syntax Errors

### Mistake:
```bash
# Trying to use multi-line commands incorrectly in PowerShell
aws sts assume-role \
  --role-arn arn:aws:iam::<666802050099>:role/OrganizationAccountAccessRole \
  --role-session-name OrgAccountAccess
```

### Issues:
- Using backslash `\` for line continuation (Linux/Mac syntax) in PowerShell
- Adding angle brackets `<>` around account ID in ARN
- Trying to run incomplete commands

### Fix:
```bash
# Correct single-line command
aws sts assume-role --role-arn arn:aws:iam::666802050099:role/OrganizationAccountAccessRole --role-session-name OrgAccountAccess

# Or use PowerShell backtick for multi-line
aws sts assume-role `
  --profile jibin `
  --role-arn arn:aws:iam::666802050099:role/OrganizationAccountAccessRole `
  --role-session-name OrgAccountAccess
```

## 2. Environment Variable Setting Errors

### Mistake:
```bash
# Using Linux/Mac syntax in PowerShell
export AWS_ACCESS_KEY_ID="ASIAZWQD72QZWARYJN2G"
```

### Issue:
- Using `export` command which doesn't exist in PowerShell

### Fix:
```powershell
# Correct PowerShell syntax
$env:AWS_ACCESS_KEY_ID="ASIAZWQD72QZWARYJN2G"
$env:AWS_SECRET_ACCESS_KEY="HKep5emftojHtNYjB/5W6qo8iuTIZR/18un+Xaje"
$env:AWS_SESSION_TOKEN="FwoGZXIvYXdzEOT//..."
```

## 3. Session Token Copy-Paste Error

### Mistake:
```powershell
# Accidentally included extra text and quotes
$env:AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEND...""HKep5emftojHtNYjB/5W6qo8iuTIZR/18un+Xaje",
```

### Issue:
- Double quotes and extra content from JSON response mixed in

### Fix:
- Copy only the SessionToken value without extra JSON formatting
- Ensure clean string assignment

## 4. Terraform Configuration Errors

### Mistake 1: Malformed Policy Document
```hcl
Principal = {
  AWS = "arn:aws:iam::<816069160759>:root"  # Angle brackets
}
Resource = "arn:aws:iam::<666802050099>:role/CrossAccountS3Access"  # Angle brackets
```

### Issue:
- Including angle brackets `<>` in ARN strings

### Fix:
```hcl
Principal = {
  AWS = "arn:aws:iam::816069160759:root"  # No brackets
}
Resource = "arn:aws:iam::666802050099:role/CrossAccountS3Access"  # No brackets
```

### Mistake 2: Non-existent Resource References
```hcl
# Trying to attach policy to non-existent user/role
resource "aws_iam_user_policy_attachment" "attach_to_user" {
  user       = "DataTeamUser"  # Doesn't exist
  policy_arn = aws_iam_policy.assume_cross_account_role.arn
}
```

### Issues:
- Referencing IAM user "DataTeamUser" that doesn't exist
- Referencing IAM role "ExistingRoleName" that doesn't exist
- Switching between user and role attachment without proper resources

### Fix:
- Create the actual IAM role first
- Use proper resource references
- Implement the complete cross-account setup with all necessary components

## 5. AWS Provider Configuration Issues

### Mistake:
```hcl
provider "aws" {
  alias   = "account_b"
  profile = "account_b"  # Profile doesn't exist
}
```

### Issue:
- Referencing AWS profiles that weren't configured

### Fix:
- Either configure the profiles using `aws configure --profile account_b`
- Or use environment variables/credentials directly
- Or remove profile references and use default credentials

## 6. Token Expiration Issues

### Mistake:
- Not realizing that assumed role credentials expire
- Continuing to use expired session tokens

### Issues:
```bash
An error occurred (ExpiredToken) when calling the AssumeRole operation: The security token included in the request is expired
```

### Fix:
- Re-run the assume-role command to get fresh credentials
- Set up proper credential management or profiles
- Use AWS CLI profiles for easier credential switching

## 7. Resource Reference Errors

### Mistake:
```hcl
# Referencing resources that don't exist in current configuration
role = aws_iam_role.jibin_role.name  # Not declared
policy_arn = aws_iam_policy.jibin_role.arn  # Wrong reference
```

### Issue:
- Terraform references to resources not declared in the configuration

### Fix:
- Ensure all referenced resources are properly declared
- Use correct resource names and attributes
- Implement the complete configuration with all dependencies

## 8. S3 Command Syntax Errors

### Mistake:
```bash
aws s3 ls s3  # Invalid bucket name
```

### Issue:
- Using incomplete S3 URI

### Fix:
```bash
aws s3 ls  # List all buckets
aws s3 ls s3://bucket-name/  # List objects in specific bucket
```

## Key Lessons Learned:

1. **PowerShell vs Bash**: Different syntax for environment variables and line continuation
2. **ARN Formatting**: Never include angle brackets in actual ARN strings
3. **Resource Dependencies**: Ensure all referenced Terraform resources exist
4. **Token Management**: Understand AWS credential expiration and renewal
5. **Error Reading**: Carefully read error messages - they often indicate exactly what's wrong
6. **Provider Configuration**: Properly set up AWS CLI profiles or use environment variables consistently
7. **Cross-Account Setup**: Requires careful coordination between provider configurations and resource creation

## Final Working Solution:
The lab was completed successfully using Option 1 configuration that creates all necessary IAM roles and policies in both accounts, with proper provider setup and resource references.

<img width="666" height="29" alt="image" src="https://github.com/user-attachments/assets/ab39583e-cada-416f-80fa-7faa9e7a60ce" />

<img width="935" height="327" alt="image" src="https://github.com/user-attachments/assets/afabaf2d-0d56-4f8b-a0a3-6a326b2c2ba9" />


## References

[AWS Tutorial: Delegate access across AWS accounts using IAM roles](https://chatgpt.com/g/g-p-68c5ab47249081919ddd4124e53e1baf-hands-on-labs/c/68c5ac28-4f50-8321-b805-e9b46a14123d#:~:text=AWS%20Tutorial%3A%20Delegate,AWS%20Provider%20Documentation)

[Terraform AWS Provider Documentation](https://chatgpt.com/g/g-p-68c5ab47249081919ddd4124e53e1baf-hands-on-labs/c/68c5ac28-4f50-8321-b805-e9b46a14123d#:~:text=AWS%20Tutorial%3A%20Delegate,AWS%20Provider%20Documentation)


