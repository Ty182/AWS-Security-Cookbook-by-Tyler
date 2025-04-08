/*
------------------------------------------------------------------------------
Description:
  - Creates an S3 bucket and KMS key along with associated policies and configures GuardDuty to encrypt and send findings to the bucket.


Improvement Ideas:
  - The code has been kept simple for accessibility. Consider incorporating this code into a larger GuardDuty module to manage all GuardDuty resources in one place. You can also set up S3 bucket lifecycle policies to manage the retention of findings.


Pricing Alert:
  - Please review the pricing pages for more information.
    - https://docs.aws.amazon.com/guardduty/latest/ug/monitoring_costs.html
    - https://aws.amazon.com/s3/pricing/
    - https://aws.amazon.com/kms/pricing/
------------------------------------------------------------------------------
*/


# Import some data resources to use in the code
data "aws_caller_identity" "current" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit
}
data "aws_region" "current" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit
}
data "aws_guardduty_detector" "detector" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit

  # This assumes you've already created a GuardDuty detector in the account. You can find this with `aws guardduty list-detectors --region <region>` or in the AWS Console.
  id = "xxxxxxxxx"
}


## Step 1: Create a KMS key for GuardDuty to use to encrypt exported findings

# Ensure this is deployed in the same account where GuardDuty is managed. 
# The `account_id` used in the key policy would be the same.
resource "aws_kms_key" "guardduty" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit

  description = "KMS key for GuardDuty findings export"

  # automatically rotates the key every 12 months
  enable_key_rotation = true

  # the key will be deleted after 7 days if it is scheduled for deletion
  deletion_window_in_days = 7
}

# Create a KMS key alias for easier identification
resource "aws_kms_alias" "guardduty" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit

  name          = "alias/guardduty-findings-export"
  target_key_id = aws_kms_key.guardduty.key_id
}

# Create a KMS key policy. 
# This could be added to the KMS key resource instead but we'll get an error of "Configuration for aws_kms_key.guardduty may not refer to itself." if we try to reference the key in the policy. We would have to use "*" instead of the key ARN and that's not ideal as GuardDuty should only be able to use this particular key we've created rather than all KMS keys.
resource "aws_kms_key_policy" "guardduty" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit

  key_id = aws_kms_key.guardduty.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow GuardDuty To GenerateDataKey"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action   = "kms:GenerateDataKey"
        Resource = "${aws_kms_key.guardduty.arn}"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}",
            "aws:SourceArn" : "arn:aws:guardduty:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:detector/${data.aws_guardduty_detector.detector.id}"
          }
        }
      },
      {
        Sid    = "Allow Root Account Access to KMS Key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "*"
        Resource = "arn:aws:kms:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:key/*"
      }
    ]
  })
}


## Step 2: Create an S3 bucket for GuardDuty to export findings to

# create bucket in the same account and region where GuardDuty is managed
resource "aws_s3_bucket" "guardduty" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit

  # bucket name must be unique
  bucket = "guardduty-findings-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}"
}

# configure bucket policy, allowing GuardDuty to write to the bucket and enforcing encryption in transit and at rest
resource "aws_s3_bucket_policy" "guardduty" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit

  bucket = aws_s3_bucket.guardduty.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Deny HTTP access"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "${aws_s3_bucket.guardduty.arn}/*"
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      },
      {
        Sid    = "Allow GetBucketLocation",
        Effect = "Allow",
        Principal = {
          Service = "guardduty.amazonaws.com"
        },
        Action   = "s3:GetBucketLocation",
        Resource = "${aws_s3_bucket.guardduty.arn}",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}",
            "aws:SourceArn" : "arn:aws:guardduty:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:detector/${data.aws_guardduty_detector.detector.id}"
          }
        }
      },
      {
        Sid    = "Allow PutObject",
        Effect = "Allow",
        Principal = {
          Service = "guardduty.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.guardduty.arn}/*",
        Condition = {
          "StringEquals" : {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}",
            "aws:SourceArn" : "arn:aws:guardduty:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:detector/${data.aws_guardduty_detector.detector.id}"
          }
        }
      },
      {
        Sid    = "Deny unencrypted object uploads",
        Effect = "Deny",
        Principal = {
          Service = "guardduty.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.guardduty.arn}/*",
        Condition = {
          "StringNotEquals" : {
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      },
      {
        Sid    = "Deny incorrect encryption header",
        Effect = "Deny",
        Principal = {
          Service = "guardduty.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.guardduty.arn}/*",
        Condition = {
          "StringNotEquals" : {
            "s3:x-amz-server-side-encryption-aws-kms-key-id" : "${aws_kms_key.guardduty.arn}"
          }
        }
      },
    ]
  })
}


## Step 3: Enable GuardDuty to export findings to the S3 bucket

# This sets the equivalent AWS Console setting here, AWS GuardDuty > Settings > Findings export options > S3 bucket (Configure now)
resource "aws_guardduty_publishing_destination" "guardduty" {
  # This is the account where GuardDuty is managed
  provider = aws.security_audit

  detector_id     = data.aws_guardduty_detector.detector.id
  destination_arn = aws_s3_bucket.guardduty.arn
  kms_key_arn     = aws_kms_key.guardduty.arn

  # key and bucket policies must be set to allow GuardDuty to use the key
  depends_on = [
    aws_kms_key_policy.guardduty,
    aws_s3_bucket_policy.guardduty
  ]
}
