resource "azurerm_public_ip" "gl-lb-pub-ip" {
  name                = "gl-lb-pub-ip"
  location            = azurerm_resource_group.gl-resource-group.location
  resource_group_name = azurerm_resource_group.gl-resource-group.name
  allocation_method   = "Static"
}


#Create Load Balancer
resource "azurerm_lb" "gl-lb" {
  name                = "gl-lb"
  location            = azurerm_resource_group.gl-resource-group.location
  resource_group_name = azurerm_resource_group.gl-resource-group.name

  frontend_ip_configuration {
    name                 = "gl-lb-frontendip"
    public_ip_address_id = azurerm_public_ip.gl-lb-pub-ip.id
  }
}


#Create Loadbalancing Rules
resource "azurerm_lb_rule" "gl-inbound-rules" {
  loadbalancer_id                = azurerm_lb.gl-lb.id
  resource_group_name            = azurerm_resource_group.gl-resource-group.name
  name                           = "web-access-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "gl-lb-frontendip"
  probe_id                       = azurerm_lb_probe.web-access-inbound-probe.id
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.web-backend-pool.id}"]
}


resource "azurerm_lb_rule" "ssh-inbound-rule" {
  loadbalancer_id                = azurerm_lb.gl-lb.id
  resource_group_name            = azurerm_resource_group.gl-resource-group.name
  name                           = "ssh-access-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 15222
  backend_port                   = 22
  frontend_ip_configuration_name = "gl-lb-frontendip"
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.web-backend-pool.id}"]
}


#Create Probe
resource "azurerm_lb_probe" "web-access-inbound-probe" {
  resource_group_name = azurerm_resource_group.gl-resource-group.name
  loadbalancer_id     = azurerm_lb.gl-lb.id
  name                = "web-access-inbound-probe"
  port                = 80
}


#Create Backend Address Pool
resource "azurerm_lb_backend_address_pool" "web-backend-pool" {
  loadbalancer_id = azurerm_lb.gl-lb.id
  name            = "web-backend-pool"
}


#Automated Backend Pool Addition > Gem Configuration to add the network interfaces of the VMs to the backend pool.
resource "azurerm_network_interface_backend_address_pool_association" "primary-pool-assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.webapp.*.id[count.index]
  ip_configuration_name   = azurerm_network_interface.webapp.*.ip_configuration.0.name[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.web-backend-pool.id

}