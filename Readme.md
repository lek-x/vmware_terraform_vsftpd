# Terraform VMWare vDirector deploying script

## Description

This is a basic terraform script which deploying Ubuntu based and setting up vsftpd server VM.

#### Attention!!!
This script was written for vDirector which has two VDC, first uses for network resources (vdc_service), second  uses for compute, storage resources (vdc_standard).




## Requrements
- Linux based OS or Windows
- vDirector v.10
- Terraform (>=0.14)
- Administrator acces into vDirector
- Ansible >=2.10

## Main steps

# Terrafrom
1. Create vApp 
2. Create VM
3. Create routed network (NSX Edge)
4. Create FW, SNAT, DNAT rules
5. Create and attach to VM independed Disk

# Ansible
1. Setting up nameservers
2. Update system
3. Create users (ftpuser)
4. Create disk
    3.1 Create GPT disk
    3.2 Create LVM Group
    3.3 Create LVM Volume
    3.4 Make fs
    3.5 Add info to fstab
5. Install server vsftpd with default tls key
6. Send ssh key to server   

## Usage

# Terraform

1. Clone this repo
2. Initialize plugins
```
terraform init
```
3. Edit varriables.tf according to your values

4. Edit terraform.tfvars according to your credentials

5. Check all config
```
terraform plan
```
If all is ok
6. Deploy VM
```
terraform apply
```

To show  VM password type

```
terraform outpus pass_vm
```
# Ansible
First replace ftp_rsa.pub with your key roles/install_vsftpd/files


check playbook
```
 ansible-playbook -i inventory.ini ftp.yml --extra-vars "ansible_user=root ansible_password=your_vm_pass"  --ssh-common-args='-o StrictHostKeyChecking=no'  --check
```

run playbook
```
 ansible-playbook -i inventory.ini ftp.yml --extra-vars "ansible_user=root ansible_password=your_vm_pass"  --ssh-common-args='-o StrictHostKeyChecking=no'  
```

ssh port =22


## License

GNU GPL v3