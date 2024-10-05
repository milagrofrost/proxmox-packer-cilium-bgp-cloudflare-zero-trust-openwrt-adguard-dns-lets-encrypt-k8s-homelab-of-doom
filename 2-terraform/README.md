# Terraform Configuration for Proxmox and Kubernetes

This directory contains Terraform configuration files for setting up Proxmox VMs and a Kubernetes cluster.

## Directory Structure

- `.gitignore`: Git ignore file for Terraform state and configuration files.
- `.terraform.lock.hcl`: Lock file for Terraform providers.
- `main.tf`: Main Terraform configuration file.
- `providers.tf`: Provider configuration file.
- `terraform.tfstate`: Terraform state file.
- `terraform.tfstate.backup`: Backup of the Terraform state file.
- `terraform.tfvars`: Variables file for Terraform.
- `variables.tf`: Variables definition file.
- `README.md`: This README file.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed on your local machine.
- Proxmox server with API access.
- SSH access to the Proxmox server.


## Variables

The following variables are defined in `variables.tf`:

- `proxmox_username`: Proxmox username (e.g., `root@pam`).
- `proxmox_password`: Proxmox password.
- `proxmox_host_ip`: Proxmox host IP address.
- `vm_username`: Username for the VM.
- `vm_password`: Password for the VM.
- `k8s_master_ip`: IP address for the Kubernetes master node.
- `storage_pool_name`: Name of the storage pool in Proxmox.
- `subnet_gw`: Subnet gateway.
- `subnet_mask`: Subnet mask.
- `pve_node_name`: Proxmox node name.
- `k8s_worker_ips`: List of IP addresses for Kubernetes worker nodes.
- `template_name`: Name of the VM template.
Z
## Setup Instructions

1. Ensure that the Proxmox server is accessible and the API is enabled.
2. Customize the variables in `terraform.tfvars` as needed.
3. Initialize Terraform:

    ```sh
    terraform init
    ```

4. Plan the Terraform deployment:

    ```sh
    terraform plan
    ```

5. Apply the Terraform configuration:

    ```sh
    terraform apply
    ```

## Troubleshooting

- Check the status of the Terraform deployment:

    ```sh
    terraform show
    ```

- Verify the state of the resources:

    ```sh
    terraform state list
    ```

- Inspect the details of a specific resource:

    ```sh
    terraform state show <resource_name>
    ```

- If you encounter issues, you can destroy the resources and start over:

    ```sh
    terraform destroy
    ```

## Ignored Files

The following files and directories are ignored by Git as specified in `.gitignore`:

- `terraform.tfvars`: Contains sensitive variable values.
- `.terraform/`: Directory used by Terraform for caching.
- `*.tfstate`: Terraform state files.
- `*.tfstate.backup`: Backup of the Terraform state files.

## License

This project is licensed under the MIT License.