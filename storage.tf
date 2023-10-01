/* STORAGE ACCOUNT */

resource "azurerm_storage_account" "proj-sa" {
  count                    = var.sa-enable-bool ? 1 : 0
  name                     = join("-", ["sa", var.project])
  resource_group_name      = azurerm_resource_group.proj-rg.name
  location                 = var.location.long
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.tags
}



data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "t-kv" {
  name                        = join("-", [var.stage.short, "kv", local.project])
  location                    = azurerm_resource_group.proj-rg.location
  resource_group_name         = azurerm_resource_group.proj-rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules = [var.my_ip]
    virtual_network_subnet_ids = [azurerm_subnet.subnets["sn-pub"].id, azurerm_subnet.subnets["sn-priv"].id] 
  }

  tags = local.tags
}

resource "azurerm_key_vault_access_policy" "owner" {
  key_vault_id = azurerm_key_vault.t-kv.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [ "Get", "List" ]
  secret_permissions = [ "Get", "List" ]
  certificate_permissions = [ "Get", "List" ]
  }

resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.t-kv.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azuread_application.aad-app1.object_id

  secret_permissions = [ "Get" ]
  }
