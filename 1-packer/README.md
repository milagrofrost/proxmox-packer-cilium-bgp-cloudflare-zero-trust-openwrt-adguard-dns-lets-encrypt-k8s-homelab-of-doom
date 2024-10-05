# Packer Kubernetes Setup

This directory contains Packer configuration files for setting up a Kubernetes cluster on Proxmox.

## Directory Structure

- `build.pkr.hcl`: Main Packer configuration file.
- `custom-vars.auto.pkrvars.hcl`: Custom variables for the Packer build.
- `http/`: Directory containing HTTP server files used during the build process.
  - `user-data.tpl`: Cloud-init user data template.
- `files/`: Directory containing additional configuration files.
  - `99-pve.cfg`: Configuration file for Proxmox cloud-init support.

## Prerequisites

- [Packer](https://www.packer.io/) installed on your local machine.
- Proxmox server with API access.
- SSH access to the Proxmox server.

## Variables

The following variables are defined in `custom-vars.auto.pkrvars.hcl`:

- `proxmox_username`: Proxmox username (e.g., `root@pam`).
- `proxmox_password`: Proxmox password.
- `proxmox_api_url`: Proxmox API URL (e.g., `https://10.10.101.250:8006/api2/json`).
- `proxmox_node`: Proxmox node name.
- `kube_version`: Kubernetes version to install.
- `ssh_pass_hash`: SSH password hash for the user.

## Build Process

1. Ensure that the Proxmox server is accessible and the API is enabled.
2. Customize the variables in `custom-vars.auto.pkrvars.hcl` as needed.
3. Run the Packer build command:

    ```sh
    packer build .
    ```

## Ignored Files

The following files and directories are ignored by Git as specified in `.gitignore`:

- `packer_cache/`: Cache directory used by Packer.

## Provisioners

The Packer configuration uses shell provisioners to:

1. Install necessary packages and configure containerd.
2. Set up Kubernetes repositories and install Kubernetes components.
3. Install Helm.

## Additional Configuration

- `http/user-data.tpl`: Cloud-init user data template used during the build process.
- `files/99-pve.cfg`: Configuration file for Proxmox cloud-init support.

## License

This project is licensed under the MIT License.