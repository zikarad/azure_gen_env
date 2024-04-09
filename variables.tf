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
  type = map

  default = {
    publisher = "Canonical"
    #    offer = "0001-com-ubuntu-server-focal-daily"
    #    sku = "20_04-daily-lts"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
  }
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

variable "jh-accnic" {
  default = false
}

variable "web-size" {
  default = "Standard_B2s"
}

variable "web-count" {
  default = 0
}

variable "web-accnic" {
  default = false
}

variable "web-os-disk-caching" {
  type = string
  default = "ReadWrite"
}

variable "web-os-disk-type" {
  type = string
  default = "Standard_LRS"
}

variable "web-data-disk-count" {
  type = number
  default = 1
}

variable "web-data-disk-size" {
  type = number
  default = 32
}

variable "web-data-disk-type" {
  type = string
  default = "Standard_LRS"
}

variable "web-data-disk-caching" {
  type = string
  default = "ReadWrite"
}

variable "sa-enable-bool" {
  default = false
}

variable "my_ip" {}
