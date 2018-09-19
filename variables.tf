variable "prefix" {
  default = "tfvmex"
}

variable location {
	default = "West Europe"
}

variable os_publisher {
	default = "Canonical"
}

variable os_offer {
	default = "UbuntuServer"
}

variable os_sku {
	default = "18.04-LTS"
}

variable db_port {
        default = "3306"
}

variable azure_subscription_id {
	type = "string"
}

variable azure_client_id {
	type = "string"
}

variable azure_client_secret {
	type = "string"
}

variable azure_tenant_id {
	type = "string"
}

variable "admin_user_username" {
	default = "azure_user"
}

variable vm_password {
	type  = "string"
}
