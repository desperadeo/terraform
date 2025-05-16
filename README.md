# Terraform

## 📦 Purpose

This repository aims to replace existing Ansible playbooks used to provision virtual machines on VMware vSphere, by using Terraform for an **approach Infrastructure as Code** (IaC). Ansible will remain in use for post-installation tasks such as system configuration and middleware deployment.

In the long term, the goal is to make this setup hypervisor-agnostic, with support for other platforms like Proxmox VE, and OpenStack.

## 🛠️ Tech Stack

- **Terraform**: Infrastructure provisioning (currently VMware vSphere; Proxmox VE and OpenStack planned).
- **Ansible**: Post-deployment configuration (OS setup, package installation, middleware, etc.).

## 🔁 Workflow Overview

### Terraform Scope

- Provisions virtual machines on the chosen hypervisor.
- Configures base resources (CPU, RAM, disk, network, etc.).
- Sets initial parameters (hostname, static IP, etc.).

### Ansible Scope

- Triggered after infrastructure is created.-
- Handles system configuration, service setup, and middleware deployment.

## 📁 Project Structure

```shell
.
├── hypervisors/
│   ├── vsphere/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── proxmox/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── openstack/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── ansible/
│   ├── inventory/
│   ├── roles/
│   └── playbooks/
│       └── post_install.yml
│
├── modules/
│   └── common_vm/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   ├── dev/
│   │   └── terraform.tfvars
│   └── prod/
│       └── terraform.tfvars
│
├── .gitignore
└── README.md
```

## 🚧 Roadmap

- Support for multiple hypervisors (VMware vSphere, Proxmox VE, OpenStack).
- Dynamic variable management via `.tfvars` files.
- CI/CD pipeline integration for full automation.
- Clear documentation of target environments.
- Full lifecycle management (create, update, destroy).

## License

The Ninja Ghost (TNG)
