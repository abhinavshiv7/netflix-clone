# The Global VPC
resource "google_compute_network" "netflix_vpc" {
  name                    = "netflix-global-vpc"
  auto_create_subnetworks = false # Best practice: Custom subnets only
}

# Subnet A: US West (Primary)
resource "google_compute_subnetwork" "subnet_us" {
  name          = "netflix-subnet-us"
  region        = "us-west1"
  network       = google_compute_network.netflix_vpc.id
  ip_cidr_range = "10.0.1.0/24"
}

# Subnet B: Asia South (Secondary/Active)
resource "google_compute_subnetwork" "subnet_asia" {
  name          = "netflix-subnet-asia"
  region        = "asia-south1" # Mumbai
  network       = google_compute_network.netflix_vpc.id
  ip_cidr_range = "10.0.2.0/24"
}

# Firewall: Allow internal traffic & SSH (Optional for debugging)
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.netflix_vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  source_ranges = ["10.0.0.0/16"]
}