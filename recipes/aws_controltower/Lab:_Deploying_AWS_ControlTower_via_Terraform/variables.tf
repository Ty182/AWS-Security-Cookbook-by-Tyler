variable "log_archive_account_name" {
  type        = string
  description = "The name of the log archive account."
}

variable "log_archive_account_email" {
  type        = string
  description = "The email of the log archive account."
}

variable "security_audit_account_name" {
  type        = string
  description = "The name of the security audit account."
}

variable "security_audit_account_email" {
  type        = string
  description = "The email of the security audit account."
}

variable "define_governedRegions" {
  type        = set(string)
  description = "A set of regions to be governed."
}

variable "set_loggingBucketRetentionDays" {
  type        = string
  description = "The number of days to retain logs in the logging bucket."
}

variable "set_accessLoggingBucketRetentionDays" {
  type        = string
  description = "The number of days to retain access logs in the logging bucket."
}

variable "enable_identityCenter" {
  type        = bool
  description = "Whether to enable the identity center. Defaults to true."
  default     = true
}

variable "set_securityOuName" {
  type        = string
  description = "The name of the security organizational unit. Defaults to 'Core'."
  default     = "Core"
}

variable "set_sandboxOuName" {
  type        = string
  description = "The name of the sandbox organizational unit. Defaults to 'Sandbox'."
  default     = "Sandbox"
}
