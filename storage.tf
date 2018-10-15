resource "azurerm_storage_account" "sa-proj1" {
  name                     = "sarz${var.prefix}"
  resource_group_name      = "${azurerm_resource_group.RG1.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags {
    environment = "development"
  }
}
