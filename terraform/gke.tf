# ---------------------------------------------------------
# Cluster 1: US Region
# ---------------------------------------------------------
resource "google_container_cluster" "primary_us" {
  name     = "netflix-cluster-us"
  location = "us-west1-a"  # Zonal cluster for cost savings (Regional is better for prod)
  
  # Attach to our custom network
  network    = google_compute_network.netflix_vpc.name
  subnetwork = google_compute_subnetwork.subnet_us.name

  # We create a minimal default node pool and remove it immediately
  # (Standard GKE Terraform practice to avoid lock-in)
  remove_default_node_pool = true
  initial_node_count       = 1
}

# Autoscaling Node Pool for US
resource "google_container_node_pool" "primary_nodes_us" {
  name       = "us-node-pool"
  location   = "us-west1-a"
  cluster    = google_container_cluster.primary_us.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5 # Grows up to 5 servers if traffic spikes
  }

  node_config {
    preemptible  = true # Uses spot instances (cheaper!)
    machine_type = "e2-medium"
    
    # Required Scopes for GKE to talk to other GCP services
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# ---------------------------------------------------------
# Cluster 2: Asia Region
# ---------------------------------------------------------
resource "google_container_cluster" "secondary_asia" {
  name     = "netflix-cluster-asia"
  location = "asia-south1-a"
  
  network    = google_compute_network.netflix_vpc.name
  subnetwork = google_compute_subnetwork.subnet_asia.name

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "secondary_nodes_asia" {
  name       = "asia-node-pool"
  location   = "asia-south1-a"
  cluster    = google_container_cluster.secondary_asia.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}