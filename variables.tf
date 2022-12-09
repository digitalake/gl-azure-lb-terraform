#Create Locations - Availability Zones
variable "avzs" {
  default = ["North Europe", "West Europe"]
}


#Prefix for Corporation
variable "vmname" {
  default = "gl-linux"
}


variable "env" {
  default = "Static"
}


variable "tenant_id" {
  type = string
  default = "36b6838b-d41b-4ef5-8c96-abd06907a34e"
}


#Corporate Naming Convention Prefix for Virtual Machine Environments -"${var.corp}-${var.mgmt}-vm01"
variable "mgmt" {
  description = "corporate naming convention prefix"
  default     = "management"

}


#Specify type of resource being deployed here - "${var.corp}-${var.mgmt}-${var.webres[0]}-01"
variable "webres" {
  default = ["vm", "webapp", "slb", "appgw"]
}



#Load  Balancer Constructs
variable "private_ip" {
  default = "10.20.10.100"
}


variable "web_access_port_range" {
  description = "dedicated ports for webserver access"
  default     = [22, 80]

}

variable "admin_ssh_key_path" {
  description = "local path to public ssh-key"
  default = "~/.ssh/deploy.pub"
}