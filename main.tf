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

#Create a Resource
resource "azurerm_resource_group" "myresourcegroup" {
  name                = "${var.prefix}-RG"
  location            = "eastus"
  tags = {
    owner = "nedum"
  } 
}

# Create a Virtual Network
resource "azurerm_virtual_network" "myvirtualnetwork" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

}

# Create the subnet
resource "azurerm_subnet" "mysubnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.myresourcegroup.name
  virtual_network_name = azurerm_virtual_network.myvirtualnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
  
}
 # Associate NSG to Subnet
 resource "azurerm_subnet_network_security_group_association" "asociate-nsg" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

# Creating a Public IP
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

# Create the Network Interface Card
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



# Creating Network Security Group
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
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

   security_rule {
    name                       = "https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "nedum"
  }
}

# Create the VM
resource "azurerm_virtual_machine" "myvm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.myresourcegroup.location
  resource_group_name   = azurerm_resource_group.myresourcegroup.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  # This line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # This line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

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
    computer_name  = "hostname"
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

