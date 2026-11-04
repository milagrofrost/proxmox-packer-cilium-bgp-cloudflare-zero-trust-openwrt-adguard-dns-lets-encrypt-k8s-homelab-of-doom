I hope you like my repo name. 😎 Shoutout to Github Co-Pilot for the assist on these docs. 🤖 And I blame Github Co-Pilot for any errors in the docs. 😅 I could never. 🙌

If you see any issues with the documentation, please create an issue 🐛 or a pull request 🛠️. I'm always looking to improve my documentation 📚 and code 💻. I'm also open to suggestions 💡 on how to improve the documentation and code. I'm always looking to learn new things and new ways to do things. 📖✨

⚠️ **Disclaimer**: This is not a production-ready setup. ⚙️ This is a homelab setup. 🏠 I'm not responsible for any issues or trauma 💥 that arise from using this setup in a production environment. Use at your own risk. 🚨

# Video Walkthrough 📹

[Overly detailed run though of this deployment](https://www.youtube.com/watch?v=gD1FABxaHek)

Comes with a handful of issues that I had to troubleshoot.  This could be a good resource for you if you run into the same issues.  I also go over some of the basics of Kubernetes and Cilium setup.

# 🏠 Homelab K8S Cluster with Cilium and Cloudflare 🛡️

Create your own Kubernetes cluster 🚀 with Cilium and Cloudflare. ☁️

The intention of this project is to not only share my code of my existing homelab 💾 but also to provide a guide on how to set up your own Kubernetes cluster with Cilium and Cloudflare. 🌐 This project is a culmination of my learnings 📚 from various sources and my own experiences. 🎓 I hope that this project will help others in their journey to learn Kubernetes and networking. 🌱

- 🕸️ Cilium for service mesh, envoy proxying, and network observability.
- 🌩️ Cloudflare for DNS and Zero Trust Access.
- 🔒 Cert-Manager for Let's Encrypt publicly signed certificates.
- 🧩 ExternalDNS for automatic DNS record creation on AdGuard Home DNS service.

![Cluster Diagram](images/diagram.png)

## 🛠️ Minimum Requirements

The bare minimum requirements to run the core services ⚙️ and not any other applications.

### Between all 3 nodes:
- 💾 10 GBs - and that's really THE minimum. You will need more if you plan to run applications on the cluster. 📦
- 🧠 Any proc if you’re going to let it idle. 💤 CPU requirements really depend on what you are going to run on the cluster after setup. ⚙️
- 🖴 20 GBs of disk space. This is the minimum for the OS and the core services. 📀 You will need more if you plan to run applications on the cluster.

### Example usage of how much core services will use:

![nodes usage](images/proxmox-dash.png)

## 🖥️ Example Hardware Configuration

- 🥧 **1x Raspberry Pi 4 8GB**  
  - 🛜 OpenWrt Router
  - 🛡️ AdGuard Home DNS
  - 🕸️ bird BGP routing
- 💻 **1x Dell m4800 Laptop - 24 GBs of RAM - 1TB SSD**  
  - 🖧 Proxmox hypervisor
    - 🖥️ 1 x k8s master VM and 2x k8s worker VMs
      - 🕸️ Cilium
      - 🧩 ExternalDNS
      - 🔒 Cert-Manager
      - 🌩️ Cloudflare tunnel operator

## 📜 Setup Instructions

- [📦 Dependencies](./0-dependencies/)  
  A small list of manual, very general steps to get the environment ready for automation. 🔧
  
- [📦 Packer](1-packer/README.md)  
  Create a Proxmox VM Ubuntu template by pulling an Ubuntu image 🌐 from the internet and installing the necessary software. 💻
  
- [🌍 Terraform](2-terraform/README.md)  
  Use the Packer template to create 3 VMs on Proxmox. 💾

- [🛡️ Kubernetes and Cilium](3-k8s-setup/README.md)  
  Set up Kubernetes and Cilium on the Proxmox VMs. ⚙️

- [🌩️ Cloudflare Zero Trust](4-zero-trust/README.md)  
  Using Terraform to set up Cloudflare Zero Trust Access. 🔐

- [🎯 My First App](5-my-first-app/README.md)  
  Deploying and troubleshooting 🛠️ a simple app on the cluster. 🚀

- [🤹‍♂️ Extracurriculars](./6-extracurriculars)  
  For funsies, 😄 some extra stuff to do with the cluster. 🎉

- [🌐 All The Apps](7-all-the-apps/README.md)  
  All the apps that I have setup in my k8s cluster. 📦

- [🚑 Claude to the Rescue](8-claude-to-the-rescue/README.md)  
  How Claude Code got this homelab healthy again after a year or more of hobbling along. 🤖


## 👤 Who am I?

I'm a Cloud Engineer ☁️ by day and a Kubernetes admin 🕹️ by night. 🌙

I'm always looking to learn new things and new ways to do things. 📖✨
