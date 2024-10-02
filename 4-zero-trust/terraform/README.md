# Terraform Configuration for Cloudflare Zero Trust

This directory contains Terraform configuration files for setting up Cloudflare Zero Trust Access.

## Directory Structure

- `main.tf`: Main Terraform configuration file.
- `variables.tf`: Variables used in the Terraform configuration.
- `outputs.tf`: Outputs from the Terraform configuration.
- `terraform.tfvars`: Variable values for the Terraform configuration.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed on your local machine.
- Cloudflare account with API access.
- Cloudflare Zero Trust Access enabled.

## Variables

The following variables are defined in `variables.tf`:

- `cloudflare_account_id`: Cloudflare account ID.
- `cloudflare_zone`: Cloudflare zone name. Example value: `example.com`.
- `allowed_emails`: List of allowed email addresses for access. 

## Usage

1. Ensure that you have the necessary API access to your Cloudflare account.
2. Rename the `terraform.tfvars.example` to `terraform.tfvars`. Customize the variables in `terraform.tfvars` as needed.
3. Initialize Terraform:

    ```sh
    terraform init
    ```

4. Validate the configuration:

    ```sh
    terraform validate
    ```

5. Apply the configuration:

    ```sh
    terraform apply
    ```

## Outputs

The following outputs are defined in `outputs.tf`:

- `zone_id`: The ID of the Cloudflare zone. 

## Resources

The following resources are defined in `main.tf`:

- `cloudflare_zones`: Data source to fetch Cloudflare zones.
- `cloudflare_zero_trust_access_group`: Resource to create a Cloudflare Zero Trust Access group.
- `cloudflare_zero_trust_access_application`: Resource to create a Cloudflare Zero Trust Access application (commented out).

## Troubleshooting

- If you encounter errors related to unsupported attributes, ensure that you are using the correct attribute names and types.
- Make sure that your Cloudflare API credentials are correct and have the necessary permissions.

## License

This project is licensed under the MIT License.