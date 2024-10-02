data "cloudflare_zones" "default" {
 name = var.cloudflare_zone
}


resource "cloudflare_zero_trust_access_group" "default" {
  account_id = var.cloudflare_account_id
  name       = "Default Group"

  include = var.allowed_emails
}

resource "cloudflare_zero_trust_access_application" "default" {
  zone_id                   = data.cloudflare_zones.default.result[0].id
  name                      = "Default Application"
  domain                    = "*.${var.cloudflare_zone}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

# Allowing access to `test@example.com` email address only
resource "cloudflare_zero_trust_access_policy" "default" {
  account_id = var.cloudflare_account_id
  app_id     = cloudflare_zero_trust_access_application.default.id
  name       = "Default Policy"
  precedence = "100"
  decision   = "allow"

  include    = [{
    email_list = {
      id = cloudflare_zero_trust_access_group.default.id
    }
  }]
}