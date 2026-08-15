# terraform-cloudflare-spam-gate

An OpenTofu/Terraform module that routes a single email address to the [cf-spam-gate](https://github.com/hugoh/cf-spam-gate) Cloudflare Worker instead of a plain forwarding rule, and writes the Worker's `ROUTES` KV entry that tells it where clean (non-spam) mail for that address should actually go. One module call wires an address up end-to-end — no separate manual KV step.

This module doesn't do anything on its own — it assumes you've already deployed an instance of the [cf-spam-gate](https://github.com/hugoh/cf-spam-gate) Worker (which does the actual spam scoring and forward/reject decision) and have its `ROUTES` KV namespace ID and Worker script name on hand.

## Usage

```hcl
resource "cloudflare_email_routing_settings" "example" {
  zone_id = cloudflare_zone.example.id
}

module "spam_gate_contact" {
  source              = "github.com/hugoh/terraform-cloudflare-spam-gate?ref=v0.1.0"
  zone_id             = cloudflare_zone.example.id
  from                = "contact@example.com"
  worker_script_name  = "cf-spam-gate" # must match `name` in the Worker's wrangler.toml
  account_id          = var.account_id
  kv_namespace_id     = "..."          # the Worker's ROUTES KV namespace id
  destinations        = ["you@your-real-inbox.example"]
  threshold           = 0.5            # optional, per-recipient spam-score override
  depends_on          = [cloudflare_email_routing_settings.example]
}
```

Requires Email Routing to already be enabled on the zone (e.g. via `cloudflare_email_routing_settings` in the calling root module, as shown above) and the Worker to already be deployed under `worker_script_name`.

Works with both OpenTofu (`tofu`) and Terraform.

See [`examples/basic`](./examples/basic) for a complete, runnable example.

## Inputs

| Name | Description | Required | Default |
|---|---|---|---|
| `zone_id` | Zone the protected address belongs to. | yes | |
| `from` | Protected email address, e.g. `"contact@example.com"`. | yes | |
| `account_id` | Cloudflare account ID that owns the `ROUTES` KV namespace. | yes | |
| `kv_namespace_id` | ID of the Worker's `ROUTES` KV namespace (from `wrangler kv namespace create ROUTES`). | yes | |
| `destinations` | Where clean (non-spam) mail for `from` actually gets forwarded. | yes | |
| `worker_script_name` | Name of the deployed `cf-spam-gate` Worker script. | no | `"cf-spam-gate"` |
| `threshold` | Per-recipient spam-score threshold override (0–1). Leave unset to use the Worker's `DEFAULT_THRESHOLD`. | no | `null` |

## Outputs

| Name | Description |
|---|---|
| `rule_id` | ID of the created email routing rule. |

## Testing

Automated tests live in [`tests/`](./tests) and run against a mocked `cloudflare`
provider — no real API calls or credentials required:

```console
tofu test
```

## Versioning

Releases are cut automatically from [Conventional Commits](https://www.conventionalcommits.org/) on every merge to `main` (see `.github/workflows/release.yml`) — pin `?ref=` to a released tag rather than `main`, since `main` can contain in-progress changes.

## License

MIT — see [LICENSE](./LICENSE).
