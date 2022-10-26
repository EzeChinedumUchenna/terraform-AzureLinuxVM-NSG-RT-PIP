# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

variable "prefix" {
  default = "nedum"
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

#1. Create a Resource
resource "azurerm_resource_group" "myresourcegroup" {
  name                = "${var.prefix}-RG"
  location            = "eastus"
  tags = {
    owner = "nedum"
  } 
}

#2. Create a Virtual Network
resource "azurerm_virtual_network" "myvirtualnetwork" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

}

#3. Create the subnet
resource "azurerm_subnet" "mysubnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.myresourcegroup.name
  virtual_network_name = azurerm_virtual_network.myvirtualnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
  
}


#4. Creating Network Security Group
resource "azurerm_network_security_group" "mynsg" {
  name                = "${var.prefix}"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

  security_rule {
    name                       = "http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

   security_rule {
    name                       = "https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "SSH"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Nginx-port"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "nedum"
  }
}

 #5. Associate NSG to Subnet
 resource "azurerm_subnet_network_security_group_association" "asociate-nsg" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

#6. Get a Public IP
resource "azurerm_public_ip" "mypublicip" {
  name                = "${var.prefix}-publicip"
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  location            = azurerm_resource_group.myresourcegroup.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "nedum"
  }
}

#7. Create the Network Interface Card and associating the created Public IP 
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.mypublicip.id
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Create a VM and attach the already created NIC 
resource "azurerm_virtual_machine" "myvm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.myresourcegroup.location
  resource_group_name   = azurerm_resource_group.myresourcegroup.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"
  #custom_data           = "install-nginx.sh"
  delete_os_disk_on_termination = true     # This line to delete the OS disk automatically when deleting the VM
  delete_data_disks_on_termination = true  # This line to delete the data disks automatically when deleting the VM


 
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "nginx-vm"
    admin_username = "chinedumeze"
    admin_password = "Fitb@5044444"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  
}

 

