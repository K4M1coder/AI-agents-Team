# Packer Builder Patterns Reference

## Proxmox ISO Builder

```hcl
source "proxmox-iso" "almalinux" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = false
  node                     = var.proxmox_node

  vm_name              = "almalinux9-template"
  template_description = "AlmaLinux 9 base template - built ${timestamp()}"
  vm_id                = 9000

  iso_file    = "local:iso/AlmaLinux-9-latest-x86_64-minimal.iso"
  unmount_iso = true

  os       = "l26"
  cores    = 2
  memory   = 2048
  cpu_type = "host"

  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size    = "20G"
    storage_pool = "local-zfs"
    type         = "scsi"
    format       = "raw"
  }

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    vlan_tag = var.vlan_id
  }

  cloud_init              = true
  cloud_init_storage_pool = "local-zfs"

  http_directory = "http"
  boot_command = [
    "<up><wait>",
    "e<wait>",
    "<down><down><end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<F10>",
  ]
  boot_wait = "10s"

  ssh_username = "root"
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
}
```

## Proxmox Clone Builder

```hcl
source "proxmox-clone" "from_template" {
  proxmox_url  = var.proxmox_url
  username     = var.proxmox_username
  password     = var.proxmox_password
  node         = var.proxmox_node

  clone_vm_id = 9000  # Source template
  vm_name     = "derived-template"
  vm_id       = 9001

  cores  = 4
  memory = 4096

  ssh_username = "ansible"
  ssh_timeout  = "10m"
}
```

## VMware vSphere ISO Builder

```hcl
source "vsphere-iso" "almalinux" {
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_user
  password            = var.vsphere_password
  insecure_connection = false

  datacenter = var.vsphere_datacenter
  cluster    = var.vsphere_cluster
  datastore  = var.vsphere_datastore
  folder     = "Templates"

  vm_name = "almalinux9-template"
  guest_os_type = "rhel9_64Guest"

  CPUs    = 2
  RAM     = 2048
  RAM_reserve_all = false

  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }

  iso_paths = ["[${var.vsphere_datastore}] ISO/AlmaLinux-9-latest-x86_64-minimal.iso"]

  http_directory = "http"
  boot_command = [
    "<up><wait>",
    "e<wait>",
    "<down><down><end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<F10>",
  ]

  ssh_username = "root"
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"

  convert_to_template = true
}
```

## AWS AMI Builder

```hcl
source "amazon-ebs" "almalinux" {
  region        = var.aws_region
  instance_type = "t3.micro"

  source_ami_filter {
    filters = {
      name                = "AlmaLinux OS 9*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    most_recent = true
    owners      = ["764336703387"]  # AlmaLinux official
  }

  ami_name        = "almalinux9-hardened-${formatdate("YYYYMMDD-hhmm", timestamp())}"
  ami_description = "AlmaLinux 9 hardened golden image"

  tags = {
    Name        = "almalinux9-hardened"
    Environment = var.environment
    ManagedBy   = "packer"
    BuildDate   = timestamp()
  }

  ssh_username = "ec2-user"
}
```

## Azure ARM Builder

```hcl
source "azure-arm" "almalinux" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret

  managed_image_resource_group_name = var.azure_resource_group
  managed_image_name                = "almalinux9-hardened-${formatdate("YYYYMMDD", timestamp())}"

  os_type         = "Linux"
  image_publisher = "almalinux"
  image_offer     = "almalinux"
  image_sku       = "9-gen2"
  location        = var.azure_location
  vm_size         = "Standard_B2s"

  azure_tags = {
    ManagedBy = "packer"
    BuildDate = timestamp()
  }

  ssh_username = "packer"
}
```

## Windows Server Builder (vSphere)

```hcl
source "vsphere-iso" "windows2022" {
  vcenter_server = var.vsphere_server
  username       = var.vsphere_user
  password       = var.vsphere_password

  vm_name       = "win2022-template"
  guest_os_type = "windows2019srvNext_64Guest"

  CPUs = 4
  RAM  = 8192

  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 60000
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }

  iso_paths = [
    "[${var.vsphere_datastore}] ISO/windows_server_2022.iso",
    "[${var.vsphere_datastore}] ISO/VMware-tools-windows.iso",
  ]

  floppy_files = [
    "http/autounattend.xml",
    "scripts/setup-winrm.ps1",
  ]

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_password = var.win_admin_password
  winrm_timeout  = "30m"

  convert_to_template = true
}
```

## Kickstart (AlmaLinux/RHEL) — http/ks.cfg

```text
# AlmaLinux 9 minimal kickstart
text
lang en_US.UTF-8
keyboard us
timezone UTC --utc
rootpw --plaintext changeme
user --name=ansible --groups=wheel --plaintext --password=changeme

network --bootproto=dhcp --device=eth0 --onboot=on
firewall --enabled --service=ssh

bootloader --location=mbr
clearpart --all --initlabel
autopart --type=lvm

%packages --ignoremissing
@^minimal-environment
qemu-guest-agent
cloud-init
python3
%end

%post
systemctl enable qemu-guest-agent
systemctl enable cloud-init
%end

reboot
```text
