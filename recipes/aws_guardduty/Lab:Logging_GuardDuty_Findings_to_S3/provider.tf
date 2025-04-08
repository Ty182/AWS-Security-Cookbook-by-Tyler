# the delegated account that manages the guardduty configuration
provider "aws" {
  region  = "us-east-1"
  profile = "security_audit"
  alias   = "security_audit"
}
