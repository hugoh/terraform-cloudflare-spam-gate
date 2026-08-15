# Basic example

Wires a single protected address (`contact@example.com`) to an already-deployed
[cf-spam-gate](https://github.com/hugoh/cf-spam-gate) Worker, enabling Email Routing
on the zone first.

## Usage

```console
tofu init
tofu plan -var account_id=... -var zone_id=...
```

Before applying, replace `kv_namespace_id` in `main.tf` with the Worker's actual
`ROUTES` KV namespace ID (from `wrangler kv namespace create ROUTES`), and confirm
`worker_script_name` matches the `name` in the Worker's `wrangler.toml`.
