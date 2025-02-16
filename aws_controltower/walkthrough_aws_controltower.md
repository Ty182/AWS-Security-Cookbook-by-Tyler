# Overview

## What is AWS Control Tower?

AWS Control Tower is a service that helps you set up and govern a secure, multi-account AWS environment based on AWS best practices.

## Benefits of AWS Control Tower

1. **Automated Landing Zone Setup**: AWS Control Tower automates the setup of a landing zone, which includes multiple AWS accounts, organizational units (OUs), and guardrails.
2. **Governance and Compliance**: It provides pre-configured governance rules (guardrails) to enforce policies and compliance across your AWS environment.
3. **Centralized Management**: Offers a single dashboard to manage your Organization structure and policies.
4. **Scalability**: Using AWS Account Factory, it enables the creation and management of new AWS accounts that conform to your standards, allowing you to scale your environment as needed.
5. **Best Practices**: Ensures that your AWS environment follows AWS best practices for security, compliance, and operational efficiency.

## Setting Up
The Terraform resources for setting up an AWS Control Tower landing zone are fairly new and not as feature-rich as what's available in the AWS Management Console. There will be some steps you'll need to perform in the console after deploying your Landing Zone e.g., registering any pre-existing Organizational Units and defining guardrails like region restrictions.

Deploying the Landing Zone does take close to an hour, so be prepared to wait for the resources to be created. Additionally, making changes to the Landing Zone configuration after deployment or enabling additional features will take time to finish. 

The progress can be monitored in the AWS Management Console under the AWS Control Tower service.

![waiting on aws control tower to finish](<./screenshots/aws_controltower_waiting.png>)

----
## Resources
- https://docs.aws.amazon.com/controltower/latest/userguide/what-is-control-tower.html

----
## Terraform Deployment Code
Within `aws_controltower/code/main.tf`, I've provided Terraform code for creating an AWS Control Tower landing zone. The code assumes you're setting this up from scratch (e.g., need to set up an AWS Organization and create new AWS accounts for the Control Tower Log Archive and Audit accounts.)

The code has been left in a simplifed state (i.e., not using modules, loops, or other advanced Terraform features) to be more easily accessible. You can customize it further to meet your specific requirements.