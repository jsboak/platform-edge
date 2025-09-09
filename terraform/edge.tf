resource "google_compute_global_address" "shop" {
  name = "boutique-shop-ip"
}

resource "google_compute_managed_ssl_certificate" "shop" {
  name = "boutique-shop-cert"

  managed {
    domains = [var.shop_hostname]
  }
}

resource "google_dns_record_set" "shop" {
  managed_zone = var.dns_managed_zone
  name         = "${var.shop_hostname}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.shop.address]
}

# Cloud Armor policy attached to the frontend backend by
# k8s/prod/gcpbackendpolicy-frontend.yaml.
resource "google_compute_security_policy" "boutique_edge_prod" {
  name        = "boutique-edge-prod"
  description = "Cloud Armor policy for the prod storefront"

  rule {
    action      = "deny(403)"
    priority    = 1000
    description = "Block SQL injection"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 1001
    description = "Block cross-site scripting"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 1002
    description = "Block remote code execution"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rce-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "allow"
    priority    = 2147483647
    description = "Default rule"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
