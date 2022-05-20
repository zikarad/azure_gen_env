output "hosts-jh" {
  value = zipmap(azurerm_virtual_machine.vm-jh.*.name,
  azurerm_public_ip.pip-jh.*.ip_address)
}

output "hosts-web" {
  value = zipmap(azurerm_virtual_machine.vm-web.*.name,
  azurerm_public_ip.pip-web.*.ip_address)
}
