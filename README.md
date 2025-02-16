# 📖 ☁️ AWS Security Cookbook by Tyler
Welcome to my AWS Security Cookbook - a collection of recipes (guides) to help you learn, build, and deploy security controls in AWS! 

## Who is this for? 
- Anyone looking to gain hands-on experience in securing AWS environments, whether you're a beginner or an experienced engineer.

## What's Inside a Recipe?
  - 👨🏻‍🍳 Each recipe provides a high-level overview of a specific AWS security service, use case, or architectural design.

  - 🏗️ Infrastructure as Code (IaC)
    - Each recipe has ready-to-use Terraform code to automate deployments -- following best practices for cloud security engineers!
    - I've kept the Terraform code fairly basic (e.g., no modules or other advanced features) to maximize simplicity and understanding. Once you have a good grasp of the deployment, use it as a reference and/or customize it to your needs!

## How to Get Started
- Each recipe is self-contained, so you can start in any order! However, for simplicity, some recipes may reference others.

## What's Covered? 
- ✅ **Available recipes**

- ☑️ **Upcoming recipes**

#### Recipes 

✅ AWS Organizations

✅ AWS Control Tower

☑️ AWS Service Control Policies (SCPs)

☑️ AWS Resource Control Policies (RCPs)

☑️ AWS Declarative Policies

☑️ AWS Identity Center

☑️ And more... 

----
# FAQ 
## What if I don't know Terraform?
- No Terraform experience? No problem! I've provided all the necessary code—just follow these four simple steps:

1. Within the recipe's `code` folder run `terraform init`
2. Then `terraform plan` to see what will be built
3. Then `terraform apply` to build the resources
4. When you're done, run `terraform destroy` to delete the resources (good to avoid unneeded costs!) 

- If you want to learn Terraform though here are some resources:
  - [Terraform on AWS: From Zero to Cloud Infrastructure](https://cybr.com/courses/terraform-on-aws-from-zero-to-cloud-infrastructure/) (A course I developed with Christophe Limpalair from Cybr.com)
  - [Official HashiCorp documentation](https://developer.hashicorp.com/terraform?product_intent=terraform)

## How much will this cost?
- This content is completely free! However, some recipes may spin up AWS resources that incur costs.
- Being mindful of cloud costs is an important skill, and I’ll provide guidance where possible—but ultimately, you’re responsible for any charges.
- Don't let cost concerns hold you back! AWS has great documentation and transparent pricing, and many services offer free-tier options. Learning by doing is the best way to build confidence in AWS.
