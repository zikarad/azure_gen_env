variable "project" {
  default = "example1"
}

variable "stage" {
  default = "test"
}

variable "stage_sh" {
  default = "t"
}

variable "db_port" {
  default = "3306"
}

/* AWS */
variable "ami" {
  # Only EU-CENTRAL-1
  default = "ami-0fe525d17aa2b4240"
}

variable "region" {
  default = "eu-central-1"
}

variable "sshkey_path" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}


/* Azure */
variable "azure_subscription_id" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "location" {
  default = "West Europe"
}

variable "location_sh" {
  default = "we"
}

variable "os_publisher" {
  default = "Canonical"
}

variable "os_offer" {
  default = "UbuntuServer"
}

variable "os_sku" {
  default = "18.04-LTS"
}

variable "azure_admin_username" {
  default = "azuser"
}

variable "jh-size" {
  default = "Standard_B2s"
}

variable "jh-count" {
  default = 1
}

variable "web-size" {
  default = "Standard_B2s"
}

variable "web-count" {
  default = 0
}

variable "sa-enable-bool" {
  default = false
}

variable "sshkey_name" {
  default = "azure-test1"
}

variable "vm_password" {}
variable "my_ip" {}
