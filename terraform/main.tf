terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
  # We will use a local backend for now. 
  # In production, you would switch this to a GCS bucket.
  backend "local" {}
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}