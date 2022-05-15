output "host_info" {
  value = zipmap(azurerm_virtual_machine.vm-jh.*.name,
    azurerm_public_ip.pip-jh.*.ip_address)
}
