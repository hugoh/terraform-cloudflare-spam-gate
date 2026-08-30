mock_provider "cloudflare" {}

variables {
  zone_id         = "test-zone-id"
  from            = "contact@example.com"
  account_id      = "test-account-id"
  kv_namespace_id = "test-kv-namespace-id"
  destinations    = ["you@your-real-inbox.example"]
}

run "defaults" {
  command = plan

  assert {
    condition     = var.worker_script_name == "cf-spam-gate"
    error_message = "worker_script_name should default to cf-spam-gate"
  }

  assert {
    condition     = cloudflare_email_routing_rule.spam_gated.actions[0].value[0] == "cf-spam-gate"
    error_message = "routing rule should point at the default worker script"
  }

  assert {
    condition     = jsondecode(cloudflare_workers_kv.route.value).destinations[0] == "you@your-real-inbox.example"
    error_message = "KV value should encode the given destinations"
  }

  assert {
    condition     = !can(jsondecode(cloudflare_workers_kv.route.value).threshold)
    error_message = "KV value should omit threshold when unset"
  }
}

run "with_threshold" {
  command = plan

  variables {
    threshold = 0.5
  }

  assert {
    condition     = jsondecode(cloudflare_workers_kv.route.value).threshold == 0.5
    error_message = "KV value should include threshold when set"
  }
}

run "custom_worker_script_name" {
  command = plan

  variables {
    worker_script_name = "custom-worker"
  }

  assert {
    condition     = cloudflare_email_routing_rule.spam_gated.actions[0].value[0] == "custom-worker"
    error_message = "routing rule should point at the overridden worker script"
  }
}
