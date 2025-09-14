# Lab 2: Policy Breakage

## Table of Contents
- [Overview](#overview)
- [Learning Objective](#learning-objective)
- [Prerequisites](#prerequisites)
- [Step-by-Step Instructions](#step-by-step-instructions)
- [Verification Steps](#verification-steps)
- [Cleanup Instructions](#cleanup-instructions)
- [Troubleshooting](#troubleshooting)

## Overview

This lab demonstrates the security implications of overly permissive IAM policies compared to least privilege policies. You will create an IAM user with a restrictive policy, test its limitations, then replace it with a wildcard policy and observe the security impact through CloudTrail logging.

## Learning Objective

By the end of this lab, you will understand:
- The difference between least privilege and over-broad IAM policies
- How to break restrictive policies by escalating to wildcard permissions
- How to capture evidence of policy violations through CloudTrail
- The importance of policy auditing and monitoring

## Prerequisites

- AWS CLI installed and configured with appropriate credentials
- Administrative access to an AWS account
- Basic understanding of IAM policies and S3
- CloudTrail enabled in your AWS account

## Step-by-Step Instructions

### Step 1: Create S3 Bucket and Test Upload

**Rationale:** Establish a test environment with an S3 bucket that we'll use to demonstrate policy restrictions and escalations.

1. Create a unique S3 bucket:
   ```bash
   aws s3 mb s3://policy-test-bucket-$(date +%s)
   # Note: Replace with your actual bucket name for subsequent commands
   export BUCKET_NAME=policy-test-bucket-$(date +%s)
   ```

2. Create a test file and upload it:
   ```bash
   echo "This is a test file for policy demonstration" > test-file.txt
   aws s3 cp test-file.txt s3://$BUCKET_NAME/
   ```

**Expected Outcome:** Bucket created successfully and file uploaded.

### Step 2: Create IAM User with Restrictive Policy

**Rationale:** Create a user with minimal permissions (GetObject only) to demonstrate least privilege principle.

1. Create IAM user:
   ```bash
   aws iam create-user --user-name policy-test-user
   ```

2. Create access keys for the user:
   ```bash
   aws iam create-access-key --user-name policy-test-user
   # Save the AccessKeyId and SecretAccessKey from output
   ```

3. Create restrictive policy document:
   ```bash
   cat > restrictive-policy.json << 'EOF'
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
           },
           {
               "Effect": "Allow",
               "Action": "s3:ListBucket",
               "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME"
           }
       ]
   }
   EOF
   # Replace YOUR_BUCKET_NAME with actual bucket name
   ```

4. Attach policy to user:
   ```bash
   aws iam put-user-policy --user-name policy-test-user --policy-name RestrictiveS3Policy --policy-document file://restrictive-policy.json
   ```

**Expected Outcome:** IAM user created with read-only access to specific S3 bucket.

### Step 3: Test Restrictive Policy

**Rationale:** Validate that the restrictive policy works as intended - allowing reads but denying destructive operations.

1. Configure AWS CLI profile for test user:
   ```bash
   aws configure set aws_access_key_id YOUR_ACCESS_KEY --profile policy-test
   aws configure set aws_secret_access_key YOUR_SECRET_KEY --profile policy-test
   aws configure set region us-east-1 --profile policy-test
   ```

2. Test GetObject (should succeed):
   ```bash
   aws s3 cp s3://$BUCKET_NAME/test-file.txt downloaded-file.txt --profile policy-test
   ```

3. Test DeleteObject (should fail):
   ```bash
   aws s3 rm s3://$BUCKET_NAME/test-file.txt --profile policy-test
   ```

**Expected Outcome:** GetObject succeeds, DeleteObject fails with access denied error.

### Step 4: Replace with Permissive Wildcard Policy

**Rationale:** Demonstrate how over-broad policies can grant unintended permissions, breaking security boundaries.

1. Create permissive policy document:
   ```bash
   cat > permissive-policy.json << 'EOF'
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "s3:*",
               "Resource": "*"
           }
       ]
   }
   EOF
   ```

2. Replace the restrictive policy:
   ```bash
   aws iam put-user-policy --user-name policy-test-user --policy-name RestrictiveS3Policy --policy-document file://permissive-policy.json
   ```

**Expected Outcome:** Policy updated to grant full S3 permissions across all buckets.

### Step 5: Test Elevated Permissions

**Rationale:** Confirm that the wildcard policy now allows previously restricted operations.

1. Test DeleteObject again (should now succeed):
   ```bash
   aws s3 rm s3://$BUCKET_NAME/test-file.txt --profile policy-test
   ```

2. Verify file deletion:
   ```bash
   aws s3 ls s3://$BUCKET_NAME/ --profile policy-test
   ```

**Expected Outcome:** DeleteObject succeeds, file is removed from bucket.

### Step 6: Capture CloudTrail Evidence

**Rationale:** Demonstrate how security events are logged and can be used for audit and compliance purposes.

1. Search CloudTrail for the delete event:
   ```bash
   aws logs filter-log-events \
     --log-group-name CloudTrail/YourCloudTrailLogGroup \
     --filter-pattern "DeleteObject" \
     --start-time $(date -d '1 hour ago' +%s)000
   ```

2. Alternative: Use CloudTrail Event History in AWS Console to search for:
   - Event name: `DeleteObject`
   - User name: `policy-test-user`
   - Time range: Last hour

**Expected Outcome:** CloudTrail event showing successful DeleteObject operation by policy-test-user.

## Verification Steps

### CloudTrail Evidence Collection

1. **Console Method:**
   - Navigate to CloudTrail → Event History
   - Filter by:
     - Event name: `DeleteObject`
     - User name: `policy-test-user`
     - Time range: Last 1-2 hours
   - Take screenshot of the event details
   - Download event JSON for detailed analysis

2. **CLI Method:**
   ```bash
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteObject \
     --start-time $(date -d '2 hours ago' --iso-8601) \
     --end-time $(date --iso-8601) \
     --output json > delete-event-evidence.json
   ```

3. **Deliverables:**
   - Screenshot of CloudTrail event in AWS Console
   - JSON file containing the DeleteObject event details
   - Both files serve as proof that the policy escalation was successful

### Key Evidence Points

Look for these fields in the CloudTrail event:
- `eventName`: Should be "DeleteObject"
- `userIdentity.userName`: Should be "policy-test-user"
- `sourceIPAddress`: Your IP address
- `requestParameters.bucketName`: Your test bucket
- `requestParameters.key`: "test-file.txt"
- `responseElements`: Should be null (indicating success)
- `errorCode`: Should be absent (no error)

## Cleanup Instructions

**Important:** Always clean up resources to avoid unnecessary charges and security risks.

1. Delete IAM user and associated resources:
   ```bash
   # Delete access keys
   aws iam list-access-keys --user-name policy-test-user
   aws iam delete-access-key --user-name policy-test-user --access-key-id YOUR_ACCESS_KEY_ID
   
   # Delete user policy
   aws iam delete-user-policy --user-name policy-test-user --policy-name RestrictiveS3Policy
   
   # Delete user
   aws iam delete-user --user-name policy-test-user
   ```

2. Delete S3 bucket and contents:
   ```bash
   # Remove any remaining objects
   aws s3 rm s3://$BUCKET_NAME --recursive
   
   # Delete bucket
   aws s3 rb s3://$BUCKET_NAME
   ```

3. Clean up local files:
   ```bash
   rm -f test-file.txt downloaded-file.txt restrictive-policy.json permissive-policy.json delete-event-evidence.json
   ```

4. Remove AWS CLI profile:
   ```bash
   aws configure list-profiles
   # Remove policy-test profile from ~/.aws/credentials and ~/.aws/config
   ```

## Troubleshooting

### Common Issues

**1. "Access Denied" when creating resources**
- Ensure your primary AWS credentials have administrative privileges
- Check that your default region is set correctly

**2. "Bucket already exists" error**
- S3 bucket names must be globally unique
- Add a timestamp or random string to make it unique
- Example: `policy-test-bucket-$(date +%s)-$RANDOM`

**3. Policy not taking effect immediately**
- IAM policies can take a few seconds to propagate
- Wait 10-15 seconds between policy changes and testing

**4. CloudTrail events not appearing**
- CloudTrail events can take 5-15 minutes to appear
- Ensure CloudTrail is enabled in your region
- Check that you're looking in the correct time window

**5. AWS CLI profile issues**
- Verify profile configuration: `aws configure list --profile policy-test`
- Test profile: `aws sts get-caller-identity --profile policy-test`

### Security Notes

- **Never use wildcard policies in production** - they violate the principle of least privilege
- **Always monitor CloudTrail** for unusual activity patterns
- **Regularly audit IAM policies** for overly broad permissions
- **Use IAM Access Analyzer** to identify unused permissions
- **Implement policy versioning** for rollback capabilities

### Learning Reinforcement

**Interview Questions to Consider:**
1. What's the difference between `s3:GetObject` and `s3:*`?
2. Why is `"Resource": "*"` dangerous in IAM policies?
3. How would you detect policy escalation attacks in a production environment?
4. What AWS services help implement least privilege access?
5. How long do CloudTrail events take to appear and how long are they retained?

**Key Takeaways:**
- Least privilege policies limit blast radius of compromised credentials
- Wildcard permissions can lead to unintended access escalation
- CloudTrail provides crucial audit trails for security investigations
- Policy testing should be part of your security development lifecycle
- Always clean up test resources to maintain good security hygiene
