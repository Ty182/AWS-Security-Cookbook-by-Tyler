/*
------------------------------------------------------------------------------
Description:
  - Create and deploy Service Control Policies (SCP) to an AWS Organization.

  - Check out the official AWS documentation for more information:
    https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scp.html


Pricing Alert:
  - SCP policies are a feature of AWS Organizations and are free to use.
  - See pricing details here: https://docs.aws.amazon.com/organizations/latest/userguide/pricing.html
------------------------------------------------------------------------------
*/

## Step 1. Create an AWS Organization
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"

  # enable SCP policies for the organization
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
}

## Step 2. Create an Organization Unit (OU) Structure
resource "aws_organizations_organizational_unit" "dev_ou" {
  name      = "<nameOfOU>"                                   # name of the OU
  parent_id = aws_organizations_organization.org.roots[0].id # attach OU to the root of the organization
}

## Step 3. Create AWS Accounts
resource "aws_organizations_account" "dev_acct" {
  email             = "<accountEmail>"                                # your email
  name              = "<nameOfAccount>"                               # name of the account
  close_on_deletion = false                                           # do not close account if this resource is deleted
  parent_id         = aws_organizations_organizational_unit.dev_ou.id # OU to attach account to
}

/*
------------------------------------------------------------------------------
Important Note:
    - SCP policies do not apply to the management account of an AWS Organization.

    - There are policy count and size limitations for SCPs:
        - Policy size: 5120 characters
        - Policy limit: Max of 5 SCPs attached to Root OU, per OU, and per account
        - See more info here: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_reference_limits.html

    - The SCP policy below is an example and may not be suitable for your organization or as comprehensive as needed.
------------------------------------------------------------------------------
*/

## Step 4. Create a Service Control Policy (SCP) that protects some critical services
resource "aws_organizations_policy" "critical_services_scp" {
  name        = "ProtectCriticalServices"
  description = "Dev Service Control Policy"
  type        = "SERVICE_CONTROL_POLICY"

  # Summary: Deny these actions unless the principal is the iamadmin user from any aws account in our aws organization
  content = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Deny",
        "Action" : [
          "guardduty:AcceptInvitation",
          "guardduty:ArchiveFindings",
          "guardduty:CreateDetector",
          "guardduty:CreateFilter",
          "guardduty:CreateIPSet",
          "guardduty:CreateMembers",
          "guardduty:CreatePublishingDestination",
          "guardduty:CreateSampleFindings",
          "guardduty:CreateThreatIntelSet",
          "guardduty:DeclineInvitations",
          "guardduty:DeleteDetector",
          "guardduty:DeleteFilter",
          "guardduty:DeleteInvitations",
          "guardduty:DeleteIPSet",
          "guardduty:DeleteMembers",
          "guardduty:DeletePublishingDestination",
          "guardduty:DeleteThreatIntelSet",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateMembers",
          "guardduty:InviteMembers",
          "guardduty:StartMonitoringMembers",
          "guardduty:StopMonitoringMembers",
          "guardduty:TagResource",
          "guardduty:UnarchiveFindings",
          "guardduty:UntagResource",
          "guardduty:UpdateDetector",
          "guardduty:UpdateFilter",
          "guardduty:UpdateFindingsFeedback",
          "guardduty:UpdateIPSet",
          "guardduty:UpdatePublishingDestination",
          "guardduty:UpdateThreatIntelSet",
          "iam:CreateUser",
          "iam:AttachRolePolicy",
          "iam:DeleteRole",
          "iam:DeleteRolePermissionsBoundary",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePermissionsBoundary",
          "iam:PutRolePolicy",
          "iam:UpdateAssumeRolePolicy",
          "iam:UpdateRole",
          "iam:UpdateRoleDescription",
          "cloudtrail:Create*",
          "cloudtrail:Delete*",
          "cloudtrail:Put*",
          "cloudtrail:Start*",
          "cloudtrail:Stop*",
          "cloudtrail:Update*"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:PrincipalOrgID" : "${aws_organizations_organization.org.id}"
          },
          "ArnNotLike" : {
            "aws:PrincipalArn" : "arn:aws:iam::*:user/iamadmin"
          }
        }
      }
    ]
  })
}

# Apply SCP at the Dev OU level (only applies to the Dev account in this OU)
resource "aws_organizations_policy_attachment" "critical_services_scp" {
  policy_id = aws_organizations_policy.critical_services_scp.id
  target_id = aws_organizations_organizational_unit.dev_ou.id
}
