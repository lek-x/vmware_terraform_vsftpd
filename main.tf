provider "vcd" {
  user                 = var.v_login                     
  password             = var.v_pass                    
  auth_type            = "integrated"
  org                  = var.v_org                 
  vdc                  = var.v_vdc          
  url                  = var.url_api          
  max_retry_timeout    = 60
  allow_unverified_ssl = "true"
}

###  Creating routed network
resource "vcd_network_routed" "routed-net" {
  org = var.v_org                            
  vdc = var.v_vdc_s                  

  name         = "routed1"
  edge_gateway = var.v_edge             
  gateway      = "192.168.0.1"
  shared       = "true"
  dns1         = "8.8.8.8"
  dns2         = "8.8.4.4"

  dhcp_pool {
    start_address = "192.168.0.2"
    end_address   = "192.168.0.15"
  }

  static_ip_pool {
    start_address = "192.168.0.16"
    end_address   = "192.168.0.25"
  }
}


#Creating vAPP
resource "vcd_vapp" "ftp" {
  name = "ftp_vapp"
}

resource "vcd_vapp_org_network" "routed-net" {
  vapp_name        = vcd_vapp.ftp.name
  org_network_name = vcd_network_routed.routed-net.name
  
}
  
#Creating vNET into vAPP
#resource "vcd_vapp_network" "vnet" {
#  name               = "vAPPnet"
#  vapp_name          = vcd_vapp.ftp.name
#  gateway            = "192.168.1.1"
#  netmask            = "255.255.255.0"
#  dns1               = "192.168.1.1"
#  dns2               = "192.168.1.1"
#  dns_suffix         = "test.test"
#  guest_vlan_allowed = false
#  
#  static_ip_pool {
#    start_address = "192.168.1.2"
#    end_address   = "192.168.1.15"
#  }
#} 

#Creating VM in vAPP 
resource "vcd_vapp_vm" "ftp" {
  vapp_name     = vcd_vapp.ftp.name
  name          = var.vm_name
  catalog_name  = var.ct_name
  template_name = var.image_name
  memory        = var.ram_quantity
  cpus          = var.cpu_quantity
  cpu_cores     = 1
  storage_profile = var.storage_profile
  hardware_version  = "vmx-14"
  power_on      = "true"
  computer_name = var.host_name
  guest_properties = {
    "guest.hostname"   = var.host_name
  }
  
  network {
    type               = "org"
	adapter_type       = "vmxnet3" 
    name               = vcd_vapp_org_network.routed-net.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }
  disk {
    name        = vcd_independent_disk.ftpdisk.name
    bus_number  = 1
    unit_number = 0
  }

  depends_on = [vcd_independent_disk.ftpdisk]
}
  


#Setting up ICMP for VM1
resource "vcd_nsxv_dnat" "forIcmp" {
  org = var.v_org                      
  vdc = var.v_vdc_s                 

  edge_gateway = var.v_edge          
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  translated_address = lookup(element(vcd_vapp_vm.ftp.network, 0),"ip")
  protocol           = "icmp"
  icmp_type          = "router-advertisement"
}


#Setting up sNAT for whole network  vnet
resource "vcd_nsxv_snat" "snatvm1" {
  org = var.v_org 
  vdc = var.v_vdc_s 

  edge_gateway = var.v_edge
  network_type = "ext"
  network_name = var.ext_net

  original_address   = "192.168.0.0/24"
  translated_address = var.ext_ip
}


#Setting up dNAT for VM1
resource "vcd_nsxv_dnat" "dnatssh22" {
  org = var.v_org                       
  vdc = var.v_vdc_s                

  edge_gateway = var.v_edge         
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  original_port      = 22
  
  translated_address = lookup(element(vcd_vapp_vm.ftp.network, 0),"ip")
  translated_port    = 22
  
  protocol           = "tcp"

}

#Setting up dNAT for VM1
resource "vcd_nsxv_dnat" "dnatftp20" {
  org = var.v_org                       
  vdc = var.v_vdc_s                

  edge_gateway = var.v_edge         
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  original_port      = 20
  
  translated_address = lookup(element(vcd_vapp_vm.ftp.network, 0),"ip")
  translated_port    = 20
  
  protocol           = "tcp"

}

#Setting up dNAT for VM1
resource "vcd_nsxv_dnat" "dnatftp21" {
  org = var.v_org                       
  vdc = var.v_vdc_s                

  edge_gateway = var.v_edge         
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  original_port      = 21
  
  translated_address = lookup(element(vcd_vapp_vm.ftp.network, 0),"ip")
  translated_port    = 21
  
  protocol           = "tcp"

}

#Setting up dNAT for VM1
resource "vcd_nsxv_dnat" "dnatftp990" {
  org = var.v_org                       
  vdc = var.v_vdc_s                

  edge_gateway = var.v_edge         
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  original_port      = 990
  
  translated_address = lookup(element(vcd_vapp_vm.ftp.network, 0),"ip")
  translated_port    = 990
  
  protocol           = "tcp"

}

#Setting up dNAT for VM1
resource "vcd_nsxv_dnat" "dnatftpftppas" {
  org = var.v_org                       
  vdc = var.v_vdc_s                

  edge_gateway = var.v_edge         
  network_name = var.ext_net    
  network_type = "ext"

  original_address   = var.ext_ip
  original_port      = "40000-50000"
  
  translated_address = lookup(element(vcd_vapp_vm.ftp.network, 0),"ip")
  translated_port    = "40000-50000"
  
  protocol           = "tcp"

}

#Firewall rule for ingress traffic  ftp 20,21, 990, 40000-50000 for VM1
resource "vcd_nsxv_firewall_rule" "ftp" {
  org          = var.v_org
  vdc          = var.v_vdc_s
  edge_gateway = var.v_edge

  source {
    ip_addresses       = ["any"]
    gateway_interfaces = ["internal"]
  }

  destination {
    ip_addresses = [var.ext_ip]
  }
 
  service {
    protocol = "tcp"
    port     = "21"
  }
  service {
    protocol = "tcp"
    port     = "20"
  }
  service {
    protocol = "tcp"
    port     = "990"
  }
   service {
    protocol = "tcp"
    port     = "990"
  }
   service {
    protocol = "tcp"
    port     = "40000-50000"
  }
} 

#Firewall rule for ingress traffic  ssh port 22 and icmp ftp 20,21, 990, 40000-50000 for VM1
resource "vcd_nsxv_firewall_rule" "ssh22" {
  org          = var.v_org
  vdc          = var.v_vdc_s
  edge_gateway = var.v_edge

  source {
    ip_addresses       = ["any"]
    gateway_interfaces = ["internal"]
  }

  destination {
    ip_addresses = [var.ext_ip]
  }
  service {
    protocol = "icmp"
  }
  
  service {
    protocol = "tcp"
    port     = "22"
  }
}

resource "vcd_independent_disk" "ftpdisk" {
  vdc             = var.v_vdc 
  name            = "ftp"
  size_in_mb      = var.ext_disk_size
  bus_type        = "SCSI"
  bus_sub_type    = "VirtualSCSI"
  storage_profile = "STANDARD"
}


### Rendering inventory	
resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tmpl",
    {
      ip1 = var.ext_ip
    }
  )
  filename = "${path.module}/inventory.ini"
}


output "local_vm_ip" {
  value = lookup(element(vcd_vapp_vm.ftp.network, 0),"ip")
}

output "ext_vm_ip" {
  value = var.ext_ip
}

output "pass_for_vm" {
  value = lookup(element(vcd_vapp_vm.ftp.customization, 0),"admin_password")
  sensitive = true
}
