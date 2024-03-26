variable "resource_group_name" {}
variable "location" {}
variable "prefix_environment" {}
variable "client_id" {
    description = "Azure Client ID"
    sensitive = true
}
variable "tenant_auth_endpoint" {
    description = "Tenant authentication endpoint"
    sensitive = true
}
variable "tenant_id" {
  description = "Tenant ID"
  sensitive = true
}
