output "resource_group_name" {
  value = azurerm_resource_group.myresourcegroup
}

output "public_ip_address" {
  value = azurerm_public_ip.mypublicip.ip_address
}

output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}