/*
------------------------------------------------------------------------------
Description:
  - AWS Accounts can be provisioned this way, but AWS ControlTower and Account Factory offer better customization and guardrails. Creating an AWS Organization resource is required when enabling AWS ControlTower via API/Terraform.


Improvement Ideas:
  - The code has been kept simple for accessibility. Consider building modules for the creation of OUs and Accounts to reduce repeat code.


Pricing Alert:
  - AWS Organizations is offered at no additional charge. You are charged only for AWS resources that users and roles in your member accounts use. 
  - For more information, see the AWS Organizations pricing page: https://docs.aws.amazon.com/organizations/latest/userguide/pricing.html
------------------------------------------------------------------------------
*/

# Create an AWS Organization
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

# Create an Organization Unit (OU) Structure
resource "aws_organizations_organizational_unit" "dev_ou" {
  name      = "DEV"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "prod_ou" {
  name      = "PROD"
  parent_id = aws_organizations_organization.org.roots[0].id
}

# Create AWS Accounts
resource "aws_organizations_account" "dev_acct" {
  email             = "<yourEmail>"                                   # your email
  name              = "Dev"                                           # name of the account
  close_on_deletion = false                                           # do not close account if this resource is deleted
  parent_id         = aws_organizations_organizational_unit.dev_ou.id # OU to attach account to
}

resource "aws_organizations_account" "prod_acct" {
  email             = "yourEmail"
  name              = "Prod"
  close_on_deletion = false
  parent_id         = aws_organizations_organizational_unit.prod_ou.id
}
