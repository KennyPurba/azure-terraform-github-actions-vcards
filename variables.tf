variable "resource_group_name" {}
variable "location" {}
variable "client_id" {
  description = "Azure Client ID"
  sensitive   = true
}
variable "tenant_auth_endpoint" {
  description = "Tenant authentication endpoint"
  sensitive   = true
}
variable "tenant_id" {
  description = "Tenant ID"
  sensitive   = true
}

variable "client_secret" {
  description = "Application Client certificate secret"
  sensitive   = true
}

variable "subscription_id" {
  description = "App Subscription ID"
  sensitive   = true
}
