# utilizing awscc provider requires at least terraform v1.0.7
terraform {
  required_version = ">= 1.0.7"
}

# the official aws provider
provider "aws" {
  region = "us-east-1"
}

# utilizes AWS's Cloud Control API which has some terraform resources that are not yet supported by the 'aws' provider.
# this provider is maintained by HashiCorp (makers of terraform)
provider "awscc" {
  region = "us-east-1"
}
