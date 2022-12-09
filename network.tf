#Create Resource Groups
resource "azurerm_resource_group" "gl-resource-group" {
  name     = "gl-resource-group"
  location = var.avzs[0] #Avaialability Zone 0 always marks your Primary Region.
}



#Create Virtual Networks > Create Spoke Virtual Network
resource "azurerm_virtual_network" "gl-vnet" {
  name                = "gl-vnet"
  location            = azurerm_resource_group.gl-resource-group.location
  resource_group_name = azurerm_resource_group.gl-resource-group.name
  address_space       = ["10.20.0.0/16"]

  tags = {
    environment = "gl-net"
  }
}


#Create Subnet
resource "azurerm_subnet" "primary-subnet" {
  name                 = "primary-subnet"
  resource_group_name  = azurerm_resource_group.gl-resource-group.name
  virtual_network_name = azurerm_virtual_network.gl-vnet.name
  address_prefixes     = ["10.20.10.0/24"]
}

#Create Private Network Interfaces
resource "azurerm_network_interface" "webapp" {
  name                = "webapp-${count.index + 1}"
  location            = azurerm_resource_group.gl-resource-group.location
  resource_group_name = azurerm_resource_group.gl-resource-group.name
  count               = 2

  ip_configuration {
    name                          = "ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.primary-subnet.id
    private_ip_address_allocation = "Dynamic"

  }
}
