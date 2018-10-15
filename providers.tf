provider "aws" {
	region="${var.region}"
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
}

provider "azurerm" {
	subscription_id	= "${var.azure_subscription_id}"
	client_id		= "${var.azure_client_id}"
	client_secret	= "${var.azure_client_secret}"
	tenant_id		= "${var.azure_tenant_id}"
}
