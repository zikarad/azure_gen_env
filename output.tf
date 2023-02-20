output "project" {
  value = {
    name     = local.project
    location = local.location
    priv_net = azurerm_subnet.sn-priv.address_prefixes
    publ_net = azurerm_subnet.sn-pub.address_prefixes
  }
}

output "hosts-jh-public" {
  value = zipmap(azurerm_virtual_machine.vm-jh.*.name,
  azurerm_public_ip.pip-jh.*.ip_address)
}

output "access-jh-public" {
  value = {
    user = var.azure_admin_username
    key  = var.sshkey_path
  }
}

output "hosts-jh-private" {
  value = zipmap(azurerm_virtual_machine.vm-jh.*.name,
  azurerm_network_interface.nic-jh.*.private_ip_address)
}

output "hosts-web" {
  value = zipmap(azurerm_virtual_machine.vm-web.*.name,
  azurerm_public_ip.pip-web.*.ip_address)
}

output "key-vault" {
  value = {
    name = azurerm_key_vault.t-kv.name
    uri  = azurerm_key_vault.t-kv.vault_uri
  }
}
