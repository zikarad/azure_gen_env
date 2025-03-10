output "project" {
  value = {
    name     = local.project
    location = var.location.long
    priv_net = azurerm_subnet.subnets["sn-priv"].address_prefixes
    publ_net = azurerm_subnet.subnets["sn-pub"].address_prefixes
  }
}

output "hosts-jh" {
  value = {
    private = zipmap(azurerm_virtual_machine.vm-jh.*.name, azurerm_network_interface.pnic-jh.*.private_ip_address)
    public  = zipmap(azurerm_virtual_machine.vm-jh.*.name, azurerm_public_ip.pip-jh.*.ip_address)
  }
}

output "access-jh-public" {
  value = {
    user = var.azure_admin_username
    key  = var.sshkey_path
  }
}

output "hosts-web" {
  value = zipmap(azurerm_virtual_machine.vm-web.*.name,
  azurerm_public_ip.pip-web.*.ip_address)
}

output "hosts-be" {
  value = zipmap(azurerm_virtual_machine.vm-be.*.name,
  azurerm_network_interface.inic-be.*.private_ip_address)
}


output "key-vault" {
  value = {
    name = azurerm_key_vault.t-kv.name
    uri  = azurerm_key_vault.t-kv.vault_uri
  }
}

output "application" {
  value = {
    name = azuread_application.aad-app1.display_name
    client_id = azuread_application.aad-app1.application_id
  }
}

output "application-password" {
  value = azuread_application_password.aad-app1.value
  sensitive = true
}
