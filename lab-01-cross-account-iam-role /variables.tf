variable "account_a_id" {
  description = "AWS Account ID for Account A"
  type        = string
  default     = "816069160759"  # Change as needed
}

variable "account_b_id" {
  description = "AWS Account ID for Account B"
  type        = string
  default     = "666802050099"  # Change as needed
}

variable "bucket_name" {
  description = "Name of the S3 bucket in Account B"
  type        = string
  default     = "my-shared-bucket"  # Change as needed
}
