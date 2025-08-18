# Prod cluster for Online Boutique. Argo CD registers it as gke-prod-us-central1.
resource "google_container_cluster" "prod" {
  name                = "gke-prod-us-central1"
  location            = var.region
  enable_autopilot    = true
  deletion_protection = true

  release_channel {
    channel = "REGULAR"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
  }

  fleet {
    project = var.project_id
  }
}

# Managed Cloud Service Mesh for the prod cluster.
resource "google_gke_hub_feature" "servicemesh" {
  name     = "servicemesh"
  location = "global"
}

resource "google_gke_hub_feature_membership" "servicemesh_prod" {
  location   = "global"
  feature    = google_gke_hub_feature.servicemesh.name
  membership = google_container_cluster.prod.fleet[0].membership_id

  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
}
