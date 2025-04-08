/*
------------------------------------------------------------------------------
Description:
  - Enables centralization of root access for AWS member accounts within an AWS Organization


Pricing Alert:
  - Root Access Management is a feature of AWS Identity and Access Management (IAM) that is available at no additional charge.
  - See https://aws.amazon.com/iam/faqs/ for more information
------------------------------------------------------------------------------
*/


# Creates an AWS Organization and enables IAM Trusted Access
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "iam.amazonaws.com",
  ]
  feature_set = "ALL"
}

/*
------------------------------------------------------------------------------
Description:
    - Enables the Root Account Management and Root Account Session Management features

Description of the enabled features:
    - RootCredentialsManagement: Allows deleting the root user credentials for member accounts
    
    - RootSessions: Allows performing certain tasks that require root user credentials
------------------------------------------------------------------------------
*/
resource "aws_iam_organizations_features" "root_mgmt" {
  enabled_features = [
    "RootCredentialsManagement",
    "RootSessions"
  ]
}
