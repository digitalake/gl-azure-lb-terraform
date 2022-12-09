data "template_file" "script" {
  template = file("${path.module}/cloud_init.cfg")
}

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "webserverconfig" {
  gzip          = true
  base64_encode = true


  # Main cloud-config configuration file.
  part {
    filename     = "cloud_init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.script.rendered
  }
}


resource "azurerm_network_security_group" "gl-nsg" {
  name                = "gl-nsg"
  location            = azurerm_resource_group.gl-resource-group.location
  resource_group_name = azurerm_resource_group.gl-resource-group.name


  #Add rule for Inbound Access
  security_rule {
    name                       = "primary"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.web_access_port_range # Referenced SSH Port 22 and tcp 80 from vars.tf file.
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


#Connect NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "gl-nsg-assoc" {
  subnet_id                 = azurerm_subnet.primary-subnet.id
  network_security_group_id = azurerm_network_security_group.gl-nsg.id
}



#Availability Set - Fault Domains [Rack Resilience]
#resource "azurerm_availability_set" "vmavset" {
#  name                         = "vmavset"
#  location                     = azurerm_resource_group.corporate-production-rg.location
#  resource_group_name          = azurerm_resource_group.corporate-production-rg.name
#  platform_fault_domain_count  = 2
#  platform_update_domain_count = 2
#  managed                      = true
#  tags = {
#    environment = "gl-net"
#  }
#}


#Create Linux Virtual Machines Workloads
resource "azurerm_linux_virtual_machine" "corporate-business-linux-vm" {

  name                  = "${var.vmname}linuxvm${count.index}"
  location              = azurerm_resource_group.gl-resource-group.location
  resource_group_name   = azurerm_resource_group.gl-resource-group.name
  network_interface_ids = ["${element(azurerm_network_interface.webapp.*.id, count.index)}"]
  size                  = "Standard_B1s" # "Standard_D2ads_v5" # "Standard_DC1ds_v3" "Standard_D2s_v3"
  count                 = 2


  #Create Operating System Disk
  os_disk {
    name                 = "${var.vmname}disk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" #Consider Storage Type
  }


  #Reference Source Image from Publisher
  source_image_reference {
    publisher = "Canonical"                    #az vm image list -p "Canonical" --output table
    offer     = "0001-com-ubuntu-server-focal" # az vm image list -p "Canonical" --output table
    sku       = "20_04-lts-gen2"               #az vm image list -s "20.04-LTS" --output table
    version   = "latest"
  }


  #Create Computer Name and Specify Administrative User Credentials
  computer_name                   = "linux-vm${count.index}"
  admin_username                  = "suser${count.index}"
  disable_password_authentication = true



  #Create SSH Key for Secured Authentication - on Windows Management Server [Putty + PrivateKey]
  admin_ssh_key {
    username   = "suser${count.index}"
    public_key = file("${var.admin_ssh_key_path}")
  }

  #Deploy Custom Data on Hosts
  custom_data = data.template_cloudinit_config.webserverconfig.rendered

}