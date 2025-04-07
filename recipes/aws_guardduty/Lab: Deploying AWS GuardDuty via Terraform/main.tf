/*
------------------------------------------------------------------------------
Description:
  - Sets up AWS GuardDuty for an AWS Organization to be managed by a Delegated Administrator account


Improvement Ideas:
  - The code has been kept simple for accessibility. Consider building a module for this to deploy and enable GuardDuty for all Regions you plan to support.


Pricing Alert:
  - Enabling AWS GuardDuty will incur costs. Please review the pricing page for more information. https://docs.aws.amazon.com/guardduty/latest/ug/monitoring_costs.html
------------------------------------------------------------------------------
*/


## Step 1. Designate an AWS account to be the GuardDuty Delegated Administrator account


# get all aws accounts in the organization
data "aws_organizations_organization" "org" {
  # ensures we use the management account credentials
  provider = aws.mgmt-acct
}

locals {
  # Go through the list of AWS accounts in the organization and find the account ID of the "Security Audit" account
  security_audit_account = [for account in data.aws_organizations_organization.org.accounts : account.id if account.name == "Security Audit"][0]
}

# Delegate GuardDuty configuration and management to the "security audit" account from the management account
resource "aws_guardduty_organization_admin_account" "security_audit_delegated" {
  # delegated guardduty admin account
  provider = aws.mgmt-acct

  # delegate administration to the "security audit" account
  admin_account_id = local.security_audit_account

  depends_on = [aws_guardduty_detector.security_audit_acct]
}


## Step 2. Deploy and configure a GuardDuty detector in the delegated administrator account

# enables GuardDuty Detector in the "security audit" account (for the Region associated with the provider)
resource "aws_guardduty_detector" "security_audit_acct" {
  # delegated guardduty admin account
  provider = aws.security_audit

  # set to 'false' to suspend guardduty and keep findings otherwise all findings are deleted if this resource is destroyed
  enable = true

  # Unique findings are published within 5 minutes of detection. This sets publishing frequency of new occurrences of existing findings. 
  finding_publishing_frequency = "FIFTEEN_MINUTES" # ONE_HOUR # SIX_HOURS
}


## Step 3. Enable GuardDuty for all accounts in the organization

# Enables default GuardDuty monitoring in all member accounts in the organization
# Sets preference to 'Enable for all accounts' found in the AWS Console > GuardDuty > Accounts > Edit > Auto-enable GuardDuty (includes foundational data sources)
# This can take up to 24 hours to update all accounts in the organization, https://docs.aws.amazon.com/guardduty/latest/ug/set-guardduty-auto-enable-preferences.html
resource "aws_guardduty_organization_configuration" "enable_guardduty" {
  # delegated guardduty admin account
  provider = aws.security_audit

  # Apply to the guardduty detector managed in the "security audit" account
  detector_id = aws_guardduty_detector.security_audit_acct.id

  # Enable GuardDuty for all accounts in the organization in the Region associated with the provider
  auto_enable_organization_members = "ALL" # NEW # NONE

  # datasources {
  # Do not use. Datasources is an old way of configuring GuardDuty features and does not support newer features (the API changed). Use "aws_guardduty_organization_configuration_feature" instead.
  # }
}


## Step 4. (Optional) Enable additional GuardDuty features ("protection plans") in all accounts in the organization

# Enables GuardDuty features in all member accounts in the organization. 
# Only one feature can be enabled per resource so either create multiple resources, or use a for_each/count loop to pass in each feature you want to enable. 
# Sets Protection plans to to 'Enable for all accounts' found in the AWS Console > GuardDuty > Accounts > Edit > Protection plans
resource "aws_guardduty_organization_configuration_feature" "enable_guardduty_features" {
  provider = aws.security_audit # delegated guardduty admin account

  # Apply to the guardduty detector managed in the "security audit" account
  detector_id = aws_guardduty_detector.security_audit_acct.id

  # Feature to enable
  name = "S3_DATA_EVENTS" # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature#argument-reference

  # Enable feature for all accounts in the organization in the Region associated with the provider
  auto_enable = "ALL"

  # Only appplicable to 'RUNTIME_MONITORING' ('EKS_RUNTIME_MONITORING' is old and no longer recommended to set -- https://docs.aws.amazon.com/guardduty/latest/ug/eks-runtime-monitoring-guardduty.html) 
  # additional_configuration {
  #   auto_enable = "ALL"
  #   name        = "EKS_ADDON_MANAGEMENT" # ECS_FARGATE_AGENT_MANAGEMENT # EC2_AGENT_MANAGEMENT
  # }
}

