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
    name                = "tfpubip"
    location            = azurerm_resource_group.tfrg.location
    resource_group_name = azurerm_resource_group.tfrg.name
    allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic1" {
    name                = "nic1"
    location            = azurerm_resource_group.tfrg.location
    resource_group_name = azurerm_resource_group.tfrg.name

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.tfsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.tfpubip.id
    }
}

resource "azurerm_linux_virtual_machine" "vm1" {
    name                  = "vm1"
    location              = azurerm_resource_group.tfrg.location
    resource_group_name   = azurerm_resource_group.tfrg.name
    network_interface_ids = [azurerm_network_interface.nic1.id]
    size                  = "Standard_DS1_v2"
    disable_password_authentication = false

    os_disk {
        caching                   = "ReadWrite"
        storage_account_type      = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "22.04-LTS"
        version   = "latest"
    }

    computer_name = "vm1"
    admin_username = var.username
    admin_password = var.password
    
    # admin_ssh_key {
    #     username   = var.username
    #     public_key = file("~/.ssh/id_rsa.pub")
    # }

    connection {
        type     = "ssh"
        host     = azurerm_public_ip.tfpubip.ip_address
        user     = var.username
        password = var.password
        # private_key = file("~/.ssh/id_rsa")
    }

    tags = {
        environment = "Development"
    }

    depends_on = [azurerm_public_ip.tfpubip]
}

output "vm_ip_address" {
    value = azurerm_public_ip.tfpubip.ip_address
}