variable "location" {
    description = "The location/region where the virtual network is created"
    default     = "North Europe"
}

variable "username" {
    description = "The username for the virtual machine"
    default     = "wess"
}

variable "password" {
    description = "The password for the virtual machine"
    default     = "AsslemaYaHmema1234!"  
}

variable "number_of_vms" {
    description = "The number of virtual machines to create"
    default     = 3
}

terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>3.0.2"
        }
    }
    required_version = ">= 1.1.0"
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "tfrg" {
    name     = "tfrg"
    location = var.location
}

resource "azurerm_virtual_network" "tfvnet" {
    name                = "tfvnet"
    location            = azurerm_resource_group.tfrg.location
    resource_group_name = azurerm_resource_group.tfrg.name
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "tfsubnet" {
    name                 = "tfsubnet"
    resource_group_name  = azurerm_resource_group.tfrg.name
    virtual_network_name = azurerm_virtual_network.tfvnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "tfpubip" {
    count = var.number_of_vms
    name                = format("pubip%d", count.index + 1)
    location            = azurerm_resource_group.tfrg.location
    resource_group_name = azurerm_resource_group.tfrg.name
    allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
    count = var.number_of_vms
    name                = format("nic%d", count.index + 1)
    location            = azurerm_resource_group.tfrg.location
    resource_group_name = azurerm_resource_group.tfrg.name

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.tfsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.tfpubip[count.index].id
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    count                 = var.number_of_vms
    name                  = format("vm%d", count.index + 1)
    location              = azurerm_resource_group.tfrg.location
    resource_group_name   = azurerm_resource_group.tfrg.name
    network_interface_ids = [azurerm_network_interface.nic[count.index].id]
    size                  = "Standard_DS1_v2"
    disable_password_authentication = false

    os_disk {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18_04-lts-gen2"
        version   = "latest"
    }

    computer_name = format("vm%d", count.index + 1)
    admin_username = var.username
    admin_password = var.password
    
    # admin_ssh_key {
    #     username   = var.username
    #     public_key = file("~/.ssh/id_rsa.pub")
    # }

    connection {
        type     = "ssh"
        host     = azurerm_public_ip.tfpubip[count.index].ip_address
        user     = var.username
        password = var.password
        # private_key = file("~/.ssh/id_rsa")
    }

    tags = {
        environment = "Development"
    }
}

output "vm_ip" {
    value = azurerm_linux_virtual_machine.vm[*].public_ip_address
}