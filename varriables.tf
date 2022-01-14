variable "v_login" {
	description = "your vDirector login"
	type = string
}

variable "v_pass" {
	description = "you vDirector Pass"
	type = string
}	
variable "url_api" {
	description = "url to vDirector API"
	type = string
	default = "https://vcd6.vdcportal.ru/api" 
}

variable "v_org" {
	description = "your v_org name e.g. org_134821"
	type = string
	default = "org_134821"
}
variable "v_vdc_s" {
	description = "your service v_org name e.g. org_134821_service"
	type = string
	default = "vdc_134821_service"
}
variable "v_vdc" {
	description = "vdc name e.g. vdc_134821_standard"
	type = string
	default = "vdc_134821_standard"
}

variable "v_edge" {
	description = "name of your EDGE e.g. Edge-134821"
	type = string
	default = "Edge-134821"
}

variable "ct_name" {
	description = "Catalog name with templates e.g. EKB, MSK, NY, Ath etc."
	type = string
	default = "MSK"
}

variable "ext_net" {
	description = "name of your ext_net e.g. ExtNet_vlan_236"
	type = string
	default = "ExtNet_vlan_236"
}

variable "ext_ip" {
	description = "your external ip"
	type = string
	default = "195.19.96.127"
}


variable "cpu_quantity" {
	description = "required cpu cores"
	type = number
	default = 2
}

variable "ram_quantity" {
	description = "required ram"
	type = number
	default = 1024
}

variable "storage_profile" {
	description = "your storage profile (HDD/STANDARD, SSD/ULTRAFAST, SAS/FAST etc.)"
	type = string
	default = "FAST"
}


variable "vm_name" {
	description = "enter VM name which shows in vDirector"
	type = string
	default = "ftp1"
}

variable "host_name" {
	description = "enter VM name which shows in vDirector"
	type = string
	default = "ftp-server1"
}

variable "image_name" {
	description = "enter image_name ubuntu based"
	type = string
	default = "ubuntu20.04-x86-64"
}

variable "ext_disk_size" {
	description = "enter independed disk size in mb"
	type = string
	default = "5024"
}

