# used to enable guardduty service principal for aws organization and delegate guardduty configuration and management to another account in the organization
provider "aws" {
  region  = "us-east-1"
  profile = "mgmt"
  alias   = "mgmt-acct"
}

# the delegated account that manages the guardduty configuration
provider "aws" {
  region  = "us-east-1"
  profile = "security_audit"
  alias   = "security_audit"
}
