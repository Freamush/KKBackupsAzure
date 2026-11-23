variable "name" {
  description = "The name of the VNet resource."
  type        = string
  default     = "vnet-kk"
}

variable "rg_name" {
  description = "The name of the resource group."
  type        = string
  default     = "RG-Katies-Kitchens-Backups"
}

variable "location" {
  description = "The location of the resource group."
  type        = string
  default     = "Sweden Central"
}

variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
  default     = "kkbackupsstorage"
}

variable "IP-CIDR" {
  description = "The IP address to be used for the resource."
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnets" {
  type = map(string)
  default = {
    vm_subnet = "10.0.0.0/26"
    pe_subnet = "10.0.0.64/26"
  }
}

variable "vm_ip_address" {
  description = "The private IP address for the private endpoint."
  type        = string
  default     = "10.0.0.5"
}

variable "pe_ip_address" {
  description = "The private IP address for the private endpoint."
  type        = string
  default     = "10.0.0.70"
}

variable "username" {
  description = "The username for the virtual machine."
  type        = string
  default     = "azureuser"
}

variable "public_key" {
  description = "The public SSH key for the virtual machine."
  type        = string
}

variable "tailscale_authkey" {
  description = "Single-use, pre-authorized Tailscale auth key tagged tag:azure-router, short expiry."
  type        = string
  sensitive   = true
}

 variable "restic_cert_end_date" {
   description = "Expiry of the restic SP credential (RFC3339), not later than the cert's notAfter."
   type        = string
   default     = "2027-11-19T00:00:00Z"
 }
 