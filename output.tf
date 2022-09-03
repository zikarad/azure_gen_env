output "project" {
  value = {
    name = local.project
  }
}

output "hosts-jh" {
  value = zipmap(azurerm_virtual_machine.vm-jh.*.name,
  azurerm_public_ip.pip-jh.*.ip_address)
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
