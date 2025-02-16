/*
------------------------------------------------------------------------------
Description:
  - Create the pre-requisites for AWS Control Tower (Organizations, Logging and Security Accounts, IAM Roles), and then the AWS Control Tower Landing Zone.

  - The pre-requisites required can be found here: https://docs.aws.amazon.com/controltower/latest/userguide/lz-api-prereques.html


Improvement Ideas:
  - The code has been kept simple for accessibility. Consider building modules for the IAM Roles to reduce repeat code.


Pricing Alert:
  - Enabling AWS Control Tower will incur costs. Please review the pricing page for more information. https://aws.amazon.com/controltower/pricing/
------------------------------------------------------------------------------
*/


## Step 1. Create the organization that will contain your landing zone
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}


## Step 2. Provision shared accounts if needed ("Log Archive" and "Security Audit")
resource "aws_organizations_account" "log_archive" {
  name  = var.log_archive_account_name  # name of the account
  email = var.log_archive_account_email # email for the account
}

resource "aws_organizations_account" "security_audit" {
  name  = var.security_audit_account_name
  email = var.security_audit_account_email
}


## Step 3. Create the required IAM service roles

# Create AWSControlTowerAdmin Role
resource "aws_iam_role" "aws_control_tower_admin_role" {
  name        = "AWSControlTowerAdmin"                                                                                         # name of the role
  description = "This role provides AWS Control Tower with access to infrastructure critical to maintaining the landing zone." # description of the role
  path        = "/service-role/"                                                                                               # required for an aws service to assume the role

  # role trust policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowControlTowerServiceAssumption"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "controltower.amazonaws.com"
        }
      },
    ]
  })
}

# Create and Attach AWSControlTowerAdminPolicy Inline Policy to the AWSControlTowerAdmin Role
resource "aws_iam_role_policy" "aws_control_tower_admin_role_policy" {
  name = "AWSControlTowerAdminPolicy"
  role = aws_iam_role.aws_control_tower_admin_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ec2:DescribeAvailabilityZones",
        "Resource" : "*"
      }
    ]
  })
}

# Attach the AWSControlTowerServiceRolePolicy to the AWSControlTowerAdmin Role
resource "aws_iam_role_policy_attachment" "AWSControlTowerServiceRolePolicy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSControlTowerServiceRolePolicy"
  role       = aws_iam_role.aws_control_tower_admin_role.name
}

# Create AWSControlTowerCloudTrailRole Role
resource "aws_iam_role" "aws_control_tower_cloudtrail_role" {
  name        = "AWSControlTowerCloudTrailRole"
  description = "AWS Control Tower enables CloudTrail as a best practice and provides this role to CloudTrail. CloudTrail assumes this role to create and publish CloudTrail logs."
  path        = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailAssumption"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })
}

# Create and Attach AWSControlTowerCloudTrailRolePolicy Inline Policy to the AWSControlTowerCloudTrailRole Role
resource "aws_iam_role_policy" "aws_control_tower_cloudtrail_role_policy" {
  name = "AWSControlTowerCloudTrailRolePolicy"
  role = aws_iam_role.aws_control_tower_cloudtrail_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "logs:CreateLogStream",
        "Resource" : "arn:aws:logs:*:*:log-group:aws-controltower/CloudTrailLogs:*",
        "Effect" : "Allow"
      },
      {
        "Action" : "logs:PutLogEvents",
        "Resource" : "arn:aws:logs:*:*:log-group:aws-controltower/CloudTrailLogs:*",
        "Effect" : "Allow"
      }
    ]
  })
}

# Create AWSControlTowerStackSetRole Role
resource "aws_iam_role" "aws_control_tower_stackset_role" {
  name        = "AWSControlTowerStackSetRole"
  description = "AWS Control Tower enables CloudTrail as a best practice and provides this role to CloudTrail. CloudTrail assumes this role to create and publish CloudTrail logs."
  path        = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailAssumption"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudformation.amazonaws.com"
        }
      },
    ]
  })
}

# Create and Attach AWSControlTowerStackSetRolePolicy Inline Policy to the AWSControlTowerStackSetRole Role
resource "aws_iam_role_policy" "aws_control_tower_stackset_role_policy" {
  name = "AWSControlTowerStackSetRolePolicy"
  role = aws_iam_role.aws_control_tower_stackset_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          "arn:aws:iam::*:role/AWSControlTowerExecution"
        ],
        "Effect" : "Allow"
      }
    ]
  })
}

# Create AWSControlTowerConfigAggregatorRoleForOrganizations Role
resource "aws_iam_role" "aws_control_tower_config_aggregator_role" {
  name        = "AWSControlTowerConfigAggregatorRoleForOrganizations"
  description = "This role provides AWS Control Tower with access to infrastructure critical to maintaining the landing zone."
  path        = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowControlTowerServiceAssumption"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "controltower.amazonaws.com"
        }
      },
    ]
  })
}

# Create and Attach AWSControlTowerConfigAggregatorRoleForOrganizationsPolicy Inline Policy to the AWSControlTowerConfigAggregatorRoleForOrganizations Role
resource "aws_iam_role_policy" "aws_control_tower_config_aggregator_role_policy" {
  name = "AWSControlTowerConfigAggregatorRoleForOrganizationsPolicy"
  role = aws_iam_role.aws_control_tower_config_aggregator_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "organizations:ListAccounts",
          "organizations:DescribeOrganization",
          "organizations:ListAWSServiceAccessForOrganization"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Attach the AWSConfigRoleForOrganizations to the AWSControlTowerConfigAggregatorRoleForOrganizations Role
resource "aws_iam_role_policy_attachment" "AWSConfigRoleForOrganizations_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
  role       = aws_iam_role.aws_control_tower_config_aggregator_role.name
}


## Step 4. Create the AWS Control Tower Landing Zone
/*
------------------------------------------------------------------------------
Description:
  - This can take about an hour to initially deploy. Any changes to this after the initial deployment can take an additional hour to deploy. You can monitor the progress of the deployment in the AWS console > AWS Control Tower > Dashboard.

  - Manifest configuration can be found here: https://docs.aws.amazon.com/controltower/latest/userguide/landing-zone-schemas.html#lz-3-3-schema


Description of the manifest:
  - governedRegions: The regions that Control Tower will enforce controls in
  - centralizedLogging: The "Log Archive" account used for centralized logging of your organization (AWS CloudTrail and AWS Config)
    - retentionDays: The number of days to retain logs in the logging buckets
  - securityRoles: The "Audit" account used for auditing and alerting you of CloudTrail and AWS Config notifications, CloudWatch events, AWS Config Rule compliance changes, GuardDuty findings, and drift warnings from all of your accounts, users, OUs, and SCPs
  - accessManagement: Enables AWS Identity Center in the organization management account


Warning:
  - After deploying the landing zone, you will notice changes to the AWS Organizations terraform resource on subsequent `terraform plan` / `terraform apply`. If you've created the Organization in this terraform file, you will need to update the code to reflect its new state i.e., `aws_service_access_principals` and `enabled_policy_types` will be added to the resource.

  - If you've set `accessManagement` to `true`, you will need to check your email and accept the invite to AWS IAM Identity Center.

  - If you have existing Organizational Units (OUs) in your AWS Organizations, you will need to register these in the AWS Console > AWS Control Tower > Organization. You cannot register the OUs via the manifest below.

  - AWS Control Tower guardrails such as denying regions will need to be modified in the AWS Console > AWS Control Tower > Landing zone settings (Modify settings). You cannot configure these allowed regions via the manifest below.
------------------------------------------------------------------------------
*/

resource "awscc_controltower_landing_zone" "landing_zone" {
  version = "3.3"
  manifest = jsonencode({
    "governedRegions" : var.define_governedRegions,
    "centralizedLogging" : {
      "accountId" : "${aws_organizations_account.log_archive.id}",
      "configurations" : {
        "loggingBucket" : {
          "retentionDays" : var.set_loggingBucketRetentionDays,
        },
        "accessLoggingBucket" : {
          "retentionDays" : var.set_accessLoggingBucketRetentionDays,
        },
      },
      "enabled" : true
    },
    "securityRoles" : {
      "accountId" : "${aws_organizations_account.security_audit.id}",
    },
    "accessManagement" : {
      "enabled" : var.enable_identityCenter
    },
    "organizationStructure" : {
      "security" : {
        "name" : var.set_securityOuName
      },
      "sandbox" : {
        "name" : var.set_sandboxOuName
      }
    }
  })
}
