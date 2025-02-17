# Overview

## What are AWS Service Control Policies (SCPs)?

AWS Service Control Policies (SCPs) are a type of organization policy that you can use to control the maximum available permissions for the IAM users and roles in your organization.

These policies do not grant permissions. Instead, they define the maximum permissions that an IAM user or role can have and are similar to IAM policies in that they are JSON documents. However, rather than being attached to IAM identities, SCPs are attached to AWS accounts, organizational units (OUs) or the root of your organization.

## Deploying SCPs

As stated previously, SCPs can be attached to AWS accounts, OUs, or the root of your organization. Here is an example showing an SCP attached to the `Dev` OU:

![SCP attached to Dev OU impacting the Developer account](<./screenshots/scp_attachment.png>)


## SCP Blocking Actions

Since SCPs define the maximum permissions that an IAM user or role can have, they can be used to block actions. Here is an example showing an SCP blocking the `iam:CreateUser` action:

![scp blocking `iam:CreateUser` action](<./screenshots/scp_block_message.png>)

An important thing to note is the error message is generic and does not provide any information about the SCP that is blocking the action. This can make troubleshooting difficult, especially in organizations with multiple SCPs and other policy types that could be having an impact. In some cases, this message shows up even when it's not an SCP blocking the action!

---
## Resources
- [AWS Service Control Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scp.html)

---
## Terraform Deployment Code
Within `aws_serviceControlPolicies/code/main.tf`, I've provided Terraform code for creating an AWS Organization, AWS Organizational Units (OUs), and AWS Accounts. The code assumes you're setting this up from scratch (e.g., need to create a new AWS Organization and add member accounts). I've also included and attached an example SCP for restricting access to specific AWS services. Additionally, it includes creating an IAM user exception to accessing these services so long as the user is within the AWS Organization.

The code has been left in a simplifed state (i.e., not using modules, loops, or other advanced Terraform features) to be more easily accessible. You can customize it further to meet your specific requirements.
