# Setting up Zero Trust in Cloudflare

For every service that you tunnel through Cloudflare, you can set up Zero Trust policies to control access to those services.  This is a free feature of Cloudflare.


## Prerequisites

- Create a cloudflare account
- Buy/Add a domain for Cloudflare to manage
- Sign up for Zero Trust (Free)
- All sites that you want to tunnel through Cloudflare must be proxied through Cloudflare in order for Zero Trust to kick-in.  This means that the DNS record must be 'orange-clouded' when you look at it in the Cloudflare DNS settings.

## Setup Instructions

- RTFM: https://developers.cloudflare.com/cloudflare-one/applications/
- Create a new token for terraform to use https://developers.cloudflare.com/cloudflare-one/api-terraform/scoped-api-tokens/
- I setup mine with there permissions
```
zero-trust-terraform API token summary
This API token will affect the below accounts and zones, along with their respective permissions

All accounts - 
Access: Organizations, Identity Providers, Groups:Edit, 
Access: Apps and Policies:Edit
```

- mv terraform.tfvars.example terraform.tfvars
- update the terraform.tfvars file with your API token and other variables
- Plan and apply!!