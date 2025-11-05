#================================================================================
# .NAME
#     TERRAFORM VARIABLES — VSPHERE ENVIRONMENT
#
# .DESCRIPTION
#     This file defines all input variables required to deploy virtual machines
#     on a vSphere infrastructure using Terraform.
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
#================================================================================


#================================================================================
# VSPHERE PROVIDER CONFIGURATION
#================================================================================

variable "vsphere_server" {
  description = "FQDN or IP address of the vSphere server (vCenter)."
  type        = string
}

variable "vault_token" {
  description = "Access token used to authenticate with HashiCorp Vault."
  type        = string
  sensitive   = true
}


#================================================================================
# VSPHERE INFRASTRUCTURE RESOURCES
#================================================================================

variable "datacenter" {
  description = "Name of the vSphere datacenter where the VMs will be created."
  type        = string
}

variable "datastore" {
  description = "Name of the datastore to use for storing virtual disks (VMDK)."
  type        = string
}

variable "cluster" {
  description = "Name of the vSphere cluster hosting the virtual machines."
  type        = string
}

variable "resource_pool" {
  description = "Name of the vSphere resource pool used for VM placement."
  type        = string
}

variable "network" {
  description = "Name of the vSphere network or port group to attach VMs to."
  type        = string
}

variable "template_linux" {
  description = "Name of the Linux template to clone when deploying Linux VMs."
  type        = string
}

variable "template_windows" {
  description = "Name of the Windows template to clone when deploying Windows VMs."
  type        = string
}


#================================================================================
# VIRTUAL MACHINE CONFIGURATION
#================================================================================

variable "vms" {
  description = "Map of virtual machines (Linux and Windows) to be deployed."
  type = map(object({
    ip                 = string
    hostname           = string
    cpu                = number
    memory             = number
    os_type            = string
    additional_disk_gb = optional(number)
  }))

  validation {
    condition = alltrue([
      for vm in values(var.vms) :
      vm.cpu > 0 &&
      vm.memory >= 2048 &&
      contains(["linux", "windows"], vm.os_type)
    ])
    error_message = "Each VM must have CPU > 0, memory >= 2048 MB, and os_type must be 'linux' or 'windows'."
  }
}

variable "vm_domain" {
  description = "Domain name to join (Windows only). Leave empty for non-domain systems."
  type        = string
  default     = ""
}

variable "vm_netmask" {
  description = "Network mask (CIDR notation) for the VM IP configuration."
  type        = number
  default     = 24
}

variable "vm_dns_servers" {
  description = "List of DNS servers to configure on the virtual machines."
  type        = list(string)
}

variable "vm_gateway" {
  description = "Default gateway IP address for network routing."
  type        = string
}

variable "vm_disk_size" {
  description = "Default primary disk size for each VM (in gigabytes)."
  type        = number
  default     = 100
}


#================================================================================
# SSH CONFIGURATION (LINUX ONLY)
#================================================================================

variable "ssh_public_key" {
  description = "Public SSH key to inject into Linux VMs during provisioning."
  type        = string
  sensitive   = true
}


#================================================================================
# DOMAIN INTEGRATION (WINDOWS ONLY)
#================================================================================

variable "join_domain" {
  description = "Active Directory domain to join. Optional and used for Windows VMs only."
  type        = string
  default     = ""
}


#================================================================================
# VM METADATA AND TAGGING
#================================================================================

variable "vm_tags" {
  description = "List of descriptive tags to assign to the VMs (e.g., environment, role, owner)."
  type        = list(string)
  default     = []
}


#================================================================================
# DEFAULTS & CONVENTIONS — GLOBAL NOTES
#================================================================================
# - All IPs must be unique within the same subnet.
# - Hostnames must comply with naming standards.
# - Memory values are expressed in megabytes (MB).
# - Disk sizes are expressed in gigabytes (GB).
# - CIDR mask defaults to /24 unless specified otherwise.
#================================================================================


#===========================================================
# EXAMPLE - VM MAP USAGE
#===========================================================
# vms = {
#   linux01 = {
#     ip       = "192.168.1.101"
#     hostname = "linux01"
#     cpu      = 2
#     memory   = 4096
#     os_type  = "linux"
#   },
#   win01 = {
#     ip       = "192.168.1.201"
#     hostname = "win01"
#     cpu      = 4
#     memory   = 8192
#     os_type  = "windows"
#     additional_disk_gb = 50
#   }
# }
