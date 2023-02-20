/* STORAGE ACCOUNT */

resource "azurerm_storage_account" "proj-sa" {
  count                    = var.sa-enable-bool ? 1 : 0
  name                     = "sarztest"
  resource_group_name      = azurerm_resource_group.proj-rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.tags
}



data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "t-kv" {

  name                        = "${var.stage_sh}-kv-${local.project}"
  location                    = azurerm_resource_group.proj-rg.location
  resource_group_name         = azurerm_resource_group.proj-rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
   tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List"
    ]

    secret_permissions = [
      "Get",
      "List"
    ]

    storage_permissions = [
      "Get",
      "List"
    ]
  }

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = local.tags
}
