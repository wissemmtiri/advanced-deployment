resource "azurerm_resource_group" "tfrg" {
  location = var.resource_group_location
  name     = "tfrg"
}

resource "azurerm_virtual_network" "tf-vnet" {
  name                = "tf-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
}

resource "azurerm_subnet" "tf-subnet" {
  name                 = "tf-subnet"
  resource_group_name  = azurerm_resource_group.tfrg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "vm-public-ip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "vnet-nsg" {
  name                = "vnet-nsg"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  ip_configuration {
    name                          = "nic-ip-config"
    subnet_id                     = azurerm_subnet.tf-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-public-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-assoc" {
  network_interface_id      = azurerm_network_interface.vm-nic.id
  network_security_group_id = azurerm_network_security_group.vnet-nsg.id
}

resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm1"
  location              = azurerm_resource_group.tfrg.location
  resource_group_name   = azurerm_resource_group.tfrg.name
  network_interface_ids = [azurerm_network_interface.vm-nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "vm1"
  admin_username                  = "wess"
  disable_password_authentication = true

  admin_ssh_key {
    username = "wess"
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh
  }

  tags = {
    environment = "dev"
  }
}