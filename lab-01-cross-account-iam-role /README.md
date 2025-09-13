# Lab 01: Cross-Account IAM Role S3 Access

## Objective
Enable Account A to securely access an S3 bucket in Account B via an IAM role and trust policy.

## Scenario
- Account A (data team) must access `bucket_name` in Account B.
- Achieved by creating a cross-account IAM role in Account B that Account A can assume.

## Architecture Diagram
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

