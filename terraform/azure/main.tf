terraform {
  required_version = "> 0.11.0"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.azure_sub_id}"
  tenant_id       = "${var.azure_tenant_id}"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
  name     = "${var.tag_name}-${var.application}-rg"
  location = "${var.azure_region}"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.tag_name}-${var.application}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.tag_name}-${var.application}-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.10.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "pip" {
  name                         = "${var.tag_name}-${var.application}-pip-${count.index}"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
  count = 4

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "sg" {
  name                = "${var.tag_name}-${var.application}-sg"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8080"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "9631"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9631"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "9638"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9638"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "27017"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "28017"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "28017"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8000"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "8085"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8085"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "${var.tag_name}-${var.application}-nic${count.index}"
  location                  = "${var.azure_region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  count = 4

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.pip.*.id, count.index)}"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.rg.name}"
  }

  byte_length = 8
}

//////STORAGE///////
////////////////////

# Create initial peer
resource "azurerm_storage_account" "stor" {
  name                     = "stor${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${var.azure_region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "azurerm_storage_container" "storcont" {
  name 		              = "vhds"
  resource_group_name 	= "${azurerm_resource_group.rg.name}"
  storage_account_name 	= "${azurerm_storage_account.stor.name}"
  container_access_type = "private"
}

//////INSTANCES///////
//////////////////////
resource "azurerm_virtual_machine" "initial-peer" {
  name                  = "${var.tag_name}-${var.application}-initialpeer"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.0.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-initialpeer-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-initialpeer-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.tag_name}-${var.application}-initialpeer"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "habitat" {
    permanent_peer = true
    use_sudo       = true
    service_type   = "systemd"

    connection {
      host        = "${azurerm_public_ip.pip.0.ip_address}"
      user        = "${var.azure_image_user}"
      password    = "${var.azure_image_password}"
    }
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create mongodb instance
resource "azurerm_virtual_machine" "mongodb" {
  depends_on            = ["azurerm_virtual_machine.initial-peer"]
  name                  = "${var.tag_name}-${var.application}-mongodb"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.1.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-mongodb-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-mongodb-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.tag_name}-${var.application}-mongodb"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "habitat" {
    peer         = "${azurerm_public_ip.pip.0.ip_address}"
    use_sudo     = true
    service_type = "systemd"

    service {
      name       = "core/mongodb"
      channel    = "stable"
      user_toml  = "${file("files/mongo.toml")}"
    }

    connection {
      host        = "${azurerm_public_ip.pip.1.ip_address}"
      user        = "${var.azure_image_user}"
      password    = "${var.azure_image_password}"
    }
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create web application instance
resource "azurerm_virtual_machine" "app" {
  depends_on            = ["azurerm_virtual_machine.mongodb"]
  name                  = "${var.tag_name}-${var.application}-app"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.2.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-app-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-app-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.tag_name}-${var.application}-app"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "habitat" {
    peer         = "${azurerm_public_ip.pip.0.ip_address}"
    use_sudo     = true
    service_type = "systemd"

    service {
      binds    = ["database:mongodb.default"]
      name     = "${var.habitat_origin}/national-parks"
      topology = "standalone"
      group    = "${var.group}"
      channel  = "${var.release_channel}"
      strategy = "${var.update_strategy}"
    }

    connection {
      host        = "${azurerm_public_ip.pip.2.ip_address}"
      user        = "${var.azure_image_user}"
      password    = "${var.azure_image_password}"
    }
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Create HAProxy instance
resource "azurerm_virtual_machine" "haproxy" {
  depends_on            = ["azurerm_virtual_machine.app"]
  name                  = "${var.tag_name}-${var.application}-haproxy"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.3.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.tag_name}-${var.application}-haproxy-osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storcont.name}/${var.application}-haproxy-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.tag_name}-${var.application}-haproxy"
    admin_username = "${var.azure_image_user}"
    admin_password = "${var.azure_image_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.azure_image_user}/.ssh/authorized_keys"
      key_data = "${file("${var.azure_public_key_path}")}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  provisioner "habitat" {
    peer         = "${azurerm_public_ip.pip.0.ip_address}"
    use_sudo     = true
    service_type = "systemd"

    service {
      binds       = ["backend:national-parks.default"]
      name        = "core/haproxy"
      channel     = "stable"
      user_toml   = "${file("files/haproxy.toml")}" 
    }

    connection {
      host        = "${azurerm_public_ip.pip.3.ip_address}"
      user        = "${var.azure_image_user}"
      password    = "${var.azure_image_password}"
    }
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

# Azure Public IP Data

data "azurerm_public_ip" "permanent-peer" {
  name = "${azurerm_public_ip.pip.0.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

data "azurerm_public_ip" "mongodb" {
  name = "${azurerm_public_ip.pip.1.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

data "azurerm_public_ip" "national-parks" {
  name = "${azurerm_public_ip.pip.2.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

data "azurerm_public_ip" "haproxy" {
  name = "${azurerm_public_ip.pip.3.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}
