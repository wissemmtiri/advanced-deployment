output "resource_group_name" {
  value = azurerm_resource_group.tfrg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "master_private_key" {
  value     = tls_private_key.secureadmin_ssh.private_key_pem
  sensitive = true
}

output "slave_private_key" {
  value     = tls_private_key.secureslaveadmin_ssh.private_key_pem
  sensitive = true
}

output "private_ip_adresses" {
  value = azurerm_linux_virtual_machine.vm-slave[*].private_ip_address
}