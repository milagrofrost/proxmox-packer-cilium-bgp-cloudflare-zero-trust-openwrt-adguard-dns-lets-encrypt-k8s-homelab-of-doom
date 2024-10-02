# Proxmox

- Proxmox is used to create VMs for the Kubernetes cluster.
- Allows you to spin up 3 k8s nodes with a single physical machine.
- Ensure that your machine has virtualization enabled in the BIOS.
  - In your BIOS your virtualization setting may be called `VT-x` or `AMD-V`.
- Proxmox is very easy to install and setup.
- The machine has one physical NIC and is connected to the network.
  - Additional NICs in your machine might change the network names in the Proxmox interface than what is shown in this documentation.


## Proxmox Installation
- RTFM: https://www.proxmox.com/en/proxmox-virtual-environment/get-started
- Download the ISO from the Proxmox website.
- Write the ISO to a USB stick.
  - Balena Etcher is a good tool for this.
  - https://etcher.balena.io/#download-etcher
- Boot from the USB stick on the machine you want to install Proxmox on.
- Follow the on-screen instructions.
- Once installed, you can access the web interface by going to `https://<your-proxmox-ip>:8006`.
  - The default username is `root` and the password is the one you set during installation.

