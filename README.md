# Building an Nginx webserver on Azure using Terraform

Here will automated the creation of an Nginx web server on Azure using Terraform as an Infrastructure as Code (IaC) tool. 

First install terraform or download the Terraform binary executable for your platform and follow the steps to install since I will be using Azure as a provider so ensure that Azure CLI is installed and configured correctly.

Create one project in your desired location and name it whatever you like. cd into the project and follow the following steps:

## Variable Declaration
Create a file called variables.tf where you would declare some important variables. Check variable.tf

## Provider
Create another file called main.tf and describe the cloud provider, Azure, in this case.
To initialize Terraform, run init, and you can see that Terraform will download the provider plugin for Azurerm.

   **<em>$ terraform init</em>**


## Create a Resource Group
A resource group is a container that holds related resources for an Azure solution.

resource "azurerm_resource_group" "webserver" {
   name = "nginx-server"
   location = var.location
}


## Azure VNet Resources
Create a Vnet as shown in the terrafom code in main.tf

## Azure subnet Resources
Create a Subnet as shown in the code in main.tf


## Network Security Group
Add the following lines of code containing the Network Security Group configuration in the main.tf file:


## Creating Public IP and Network Interface
To expose our Nginx web server to the outside world, we need to create a public IP address using the azurerm_public_ip and network interface resources azurerm_network_interface. The network interface resides in the subnet and will be attached to the virtual machine exposing a web server to the outside world.

## Azure Virtual Machine Instance
Create the Azure VM as shown in the terraform code in the main.tf

## Execution Plan and Applying the Changes
You can now generate the execution plan by running the plan command and checking if everything is as expected.

**<em>$ terraform plan</em>**

You can also use the terraform validate command to check if the configuration is correct using the following command:

**<em>$ terraform validate</em>**

Once confirmed, you can proceed with the apply command to provision a new or apply the changes to the existing infrastructure.

**<em>$ terraform apply</em>**

Once successfully applied, you will get the Virtual Machines IP addresses created by Terraform. You can use the IP addresses to log in to them using SSH.

You can also explore the terraform show command to see the provisioned infrastructure’s detailed information.

Once logged in, run docker ps and see the running nginx container. Next, curl localhost, and you should visit the default nginx webpage.