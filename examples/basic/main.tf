terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

variable "account_id" {
  type = string
}

variable "zone_id" {
  type = string
}

resource "cloudflare_email_routing_settings" "example" {
  zone_id = var.zone_id
}

module "spam_gate_contact" {
  source = "../.."

  zone_id            = var.zone_id
  from               = "contact@example.com"
  worker_script_name = "cf-spam-gate"
  account_id         = var.account_id
  kv_namespace_id    = "REPLACE_WITH_ROUTES_KV_NAMESPACE_ID"
  destinations       = ["you@your-real-inbox.example"]
  threshold          = 0.5

  depends_on = [cloudflare_email_routing_settings.example]
}

output "rule_id" {
  value = module.spam_gate_contact.rule_id
}
