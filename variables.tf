#Create Locations - Availability Zones
variable "avzs" {
  default = ["North Europe", "West Europe"]
}

variable "vnet_addr_spc" {
  description = "address space for vms virtual network"
  default     = ["10.20.0.0/16"]
}

variable "subnet_pref" {
  description = "address prefixes for vms subnet"
  default     = ["10.20.10.0/24"]
}
#Prefix for Corporation
variable "vmname" {
  default = "gl-linux"
}


variable "web_access_port_range" {
  description = "dedicated ports for webserver access"
  default     = ["22", "80"]

}

variable "admin_ssh_key_path" {
  description = "local path to public ssh-key"
  default     = "~/.ssh/deploy.pub"
}