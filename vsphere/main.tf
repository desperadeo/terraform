#=================================================================================
# .NAME
#     TERRAFORM MAIN — vSphere VM DEPLOYMENT
#
# .DESCRIPTION
#     Main Terraform configuration file for deploying virtual machines
#     on a vSphere environment using templates and Vault secrets.
#
# .NOTES
#     Version   : 1.0
#     Author    : The Ninja Ghost (TNG)
#     Team      : The Avengers
#     Created   : 2025-07-05
#     Modified  : 2025-11-05
#
# .RELEASES
#     1.0 - 2025-11-05 : Initial release
#=================================================================================


#================================================================================
# MAIN TERRAFORM CONFIGURATION
#================================================================================

terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.12.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.3.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}


#================================================================================
# PROVIDERS
#================================================================================

provider "vsphere" {
  user                 = data.vault_generic_secret.vsphere.data["vsphere_user"]
  password             = data.vault_generic_secret.vsphere.data["vsphere_password"]
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "vault" {
  address         = "https://<vault>:8200"
  token           = var.vault_token
  skip_tls_verify = true
}


#================================================================================
# VSPHERE DATA SOURCES
#================================================================================

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_linux" {
  name          = var.template_linux
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_windows" {
  name          = var.template_windows
  datacenter_id = data.vsphere_datacenter.dc.id
}


#================================================================================
# VAULT DATA SOURCES — CREDENTIALS
#================================================================================

data "vault_generic_secret" "vsphere" {
  path = "secret/terraform/vsphere"
}

data "vault_generic_secret" "windows" {
  path = "secret/terraform/windows"
}


#================================================================================
# RESOURCE — VSPHERE VIRTUAL MACHINES
#================================================================================

resource "vsphere_virtual_machine" "vm" {
  for_each         = var.vms
  name             = each.value.hostname
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = each.value.cpu
  memory   = each.value.memory
  guest_id = each.value.os_type == "windows" ? data.vsphere_virtual_machine.template_windows.guest_id : data.vsphere_virtual_machine.template_linux.guest_id

  scsi_type = each.value.os_type == "windows" ? data.vsphere_virtual_machine.template_windows.scsi_type : data.vsphere_virtual_machine.template_linux.scsi_type

  firmware = each.value.os_type == "windows" ? "efi" : "bios"

  #---------------------------------------------------------------------------
  # NETWORK INTERFACE
  #---------------------------------------------------------------------------

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = each.value.os_type == "windows" ? data.vsphere_virtual_machine.template_windows.network_interface_types[0] : data.vsphere_virtual_machine.template_linux.network_interface_types[0]
  }

  #---------------------------------------------------------------------------
  # PRIMARY DISK
  #---------------------------------------------------------------------------

  disk {
    label            = "disk0"
    size             = each.value.os_type == "windows" ? data.vsphere_virtual_machine.template_windows.disks[0].size : data.vsphere_virtual_machine.template_linux.disks[0].size
    eagerly_scrub    = false
    thin_provisioned = each.value.os_type == "windows" ? data.vsphere_virtual_machine.template_windows.disks[0].thin_provisioned : data.vsphere_virtual_machine.template_linux.disks[0].thin_provisioned
    unit_number      = 0
  }

  #---------------------------------------------------------------------------
  # ADDITIONAL DISK (OPTIONAL)
  #---------------------------------------------------------------------------

  dynamic "disk" {
    for_each = lookup(each.value, "additional_disk_gb", null) != null && each.value.additional_disk_gb > 0 ? [1] : []
    content {
      label            = "disk1"
      unit_number      = 2
      size             = each.value.additional_disk_gb
      thin_provisioned = true
      eagerly_scrub    = false
    }
  }

  #---------------------------------------------------------------------------
  # CLONE & OS CUSTOMIZATION
  #---------------------------------------------------------------------------

  clone {
    template_uuid = each.value.os_type == "windows" ? data.vsphere_virtual_machine.template_windows.id : data.vsphere_virtual_machine.template_linux.id

    customize {
      # Linux options
      dynamic "linux_options" {
        for_each = each.value.os_type == "linux" ? [1] : []
        content {
          host_name = each.value.hostname
          domain    = var.vm_domain
        }
      }

      # Windows options
      dynamic "windows_options" {
        for_each = each.value.os_type == "windows" ? [1] : []
        content {
          computer_name         = each.value.hostname
          admin_password        = data.vault_generic_secret.windows.data["local_admin_password"]
          join_domain           = var.join_domain
          domain_admin_user     = data.vault_generic_secret.windows.data["domain_admin_user"]
          domain_admin_password = data.vault_generic_secret.windows.data["domain_admin_password"]
        }
      }

      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = var.vm_netmask
      }

      dns_server_list = var.vm_dns_servers
      ipv4_gateway    = var.vm_gateway
    }
  }

  #---------------------------------------------------------------------------
  # VM TAGS
  #---------------------------------------------------------------------------

  tags = var.vm_tags
}
