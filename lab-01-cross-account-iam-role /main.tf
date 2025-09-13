# Account B Provider
provider "aws" {
  alias  = "account_b"
  region = "us-east-1"
  # credentials/profile for Account B
}

# IAM Role that Account A can assume
resource "aws_iam_role" "cross_account_s3_access" {
  provider = aws.account_b
  name     = "CrossAccountS3Access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::816069160759:root"  # Account A
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach S3 access policy to the role in Account B
resource "aws_iam_role_policy" "s3_access_policy" {
  provider = aws.account_b
  name     = "S3AccessPolicy"
  role     = aws_iam_role.cross_account_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:CreateBucket",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "*"
      }
    ]
  })
}

# Account A Provider
provider "aws" {
  alias  = "account_a"
  region = "us-east-1"
  # credentials/profile for Account A
}

# Create the IAM role in Account A that will assume the cross-account role
resource "aws_iam_role" "s3_consumer_role" {
  provider = aws.account_a
  name     = "S3ConsumerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # Or whatever service will use this role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy allowing the role to assume Account B's role
resource "aws_iam_policy" "assume_cross_account_role" {
  provider = aws.account_a
  name     = "AssumeCrossAccountRolePolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::666802050099:role/CrossAccountS3Access"
      }
    ]
  })
}

# Attach policy to the role in Account A
resource "aws_iam_role_policy_attachment" "attach_assume_role_policy" {
  provider   = aws.account_a
  role       = aws_iam_role.s3_consumer_role.name
  policy_arn = aws_iam_policy.assume_cross_account_role.arn
}

# Optional: Create instance profile if this role will be used by EC2
resource "aws_iam_instance_profile" "s3_consumer_profile" {
  provider = aws.account_a
  name     = "s3-consumer-profile"
  role     = aws_iam_role.s3_consumer_role.name
}
