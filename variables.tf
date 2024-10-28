variable "project" {
  default = "example1"
}

variable "stage" {
  type = map

  default = {
    long = "test"
    short = "t"
  }
}

variable "db_port" {
  default = "5432"
}

variable "sshkey_path" {}

/* Azure */
variable "azure_subscription_id" {
  type = string
  sensitive = true
}

variable "azure_client_id" {
  type = string
  sensitive = true
}

variable "azure_client_secret" {
  type = string
  sensitive = true
}

variable "azure_tenant_id" {
  type = string
  sensitive = true
}

variable "location" {
  type = map

  default = {
    long = "West Europe"
    short = "we"
  }
}

variable "subnets_map" {
  type = map(object({
    name = string
    cidr_block = list(string)
  }))

  default = {
    sn-pub = {
      name = "public"
      cidr_block = ["10.0.1.0/24"]
    }
    sn-priv = {
      name = "private"
      cidr_block = ["10.0.2.0/24"]
    }
  }
}

variable "os_map" {
  description = "Map describing used OS image"
  type = map(object({
    publisher = string
    offer = string
    sku = string
  }))

  default = {
    arm64 = {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts-arm64"
    }
    x86_64 = {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts-gen2"
    } 
  }
}

variable "azure_admin_username" {
  default = "azuser"
}

variable "jh-platform" {
  type = string
  default = "arm64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.jh-platform)
    error_message = "Platform must be either x86_64 or arm64"
  }
}

variable "jh-size" {
  type = string
  default = "Standard_B2pls_v2"
}

variable "jh-count" {
  default = 1
}

variable "jh-accnic" {
  default = false
}

variable "sa-enable-bool" {
  default = false
}

variable "my_ip" {}

#
# Key vault variables
#
variable "sku_name" {
  type        = string
  description = "Select Standard or Premium SKU"
  default     = "standard"
}

variable "enabled_for_deployment" {
  type        = string
  description = "Allow Azure Virtual Machines to retrieve certificates stored as secrets from the Azure Key Vault"
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = string
  description = "Allow Azure Disk Encryption to retrieve secrets from the Azure Key Vault and unwrap keys"
  default     = true
}

variable "enabled_for_template_deployment" {
  type        = string
  description = "Allow Azure Resource Manager to retrieve secrets from the Azure Key Vault"
  default     = false
}
