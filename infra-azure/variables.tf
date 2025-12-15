variable "location" {
  type    = string
  default = "southeastasia"
}

variable "resource_group_name" {
  type    = string
  default = "rg-chatroom-devops"
}

variable "vm_name" {
  type    = string
  default = "chatroom-devops-vm"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH public key, e.g. C:/Users/MAS/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Your public IP CIDR for SSH, e.g. 1.2.3.4/32"
}

variable "acr_name" {
  type        = string
  default     = "acrchatroom9283"
  description = "Name of the Azure Container Registry. Must be globally unique."
}
