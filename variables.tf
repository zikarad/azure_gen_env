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
    offer = "0001-com-ubuntu-server-focal-daily"
    sku = "20_04-daily-lts"
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

variable "sa-enable-bool" {
  default = false
}

variable "my_ip" {}
