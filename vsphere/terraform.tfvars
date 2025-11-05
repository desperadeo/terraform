#=================================================================================
# .NAME
#     TERRAFORM TFVARS — vSphere ENVIRONMENT
#
# .DESCRIPTION
#     This file provides example values for all input variables defined in variables.tf
#     for deploying virtual machines on a vSphere infrastructure using Terraform.
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
# VSPHERE PROVIDER CONFIGURATION
#================================================================================

vsphere_server   = "https://<center_server_IP>"
vault_token      = ""   # Optional: Fill with your Vault token if required


#================================================================================
# SSH CONFIGURATION (LINUX ONLY)
#================================================================================

ssh_public_key   = "ssh-ed25519 xxxxxxx toan.nguyen@xxx.yyy"


#================================================================================
# DOMAIN INTEGRATION (WINDOWS ONLY)
#================================================================================

join_domain      = "<ad_domain_name>"


#================================================================================
# VSPHERE INFRASTRUCTURE RESOURCES
#================================================================================

datacenter       = "<datacenter_name>"
datastore        = "<datastore_name>"
cluster          = "<cluster_name>"
resource_pool    = "Cluster/Resources/Test/Terraform"
network          = "<portgroup_name>"

template_linux   = "TPL-ROCKY-9-20250517"
template_windows = "TPL-WIN-2022-20250626"


#================================================================================
# VM NETWORK CONFIGURATION
#================================================================================

vm_dns_servers   = ["<ntp_ip_1>", "<ntp_ip_2>"]
vm_domain        = "<ad_domain_name>"
vm_gateway       = "<gw_ip>"


#================================================================================
# VM METADATA AND TAGGING
#================================================================================

vm_tags          = ["linux", "rocky9"]


#================================================================================
# VIRTUAL MACHINES DEFINITION
#================================================================================

vms = {
  "win11-vm-1" = {
    ip                 = "<vm_1_ip>"
    hostname           = "win11-vm-1"
    cpu                = 2
    memory             = 8192
    os_type            = "windows"
    additional_disk_gb = 333
  }

  "win11-vm-2" = {
    ip                 = "<vm_2_ip>"
    hostname           = "win11-vm-2"
    cpu                = 2
    memory             = 8192
    os_type            = "windows"
    additional_disk_gb = 222
  }
}
