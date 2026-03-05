resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "database_url" {
  secret_id = "ci-demo-app-database-url"
  replication {
    auto {}
  }
  depends_on = [google_project_service.secret_manager]
}

resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = var.database_url
}

resource "google_storage_bucket" "storage" {
  name                        = "${var.project_id}-ci-demo-app-storage"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "ci-demo-app-sa"
  display_name = "ci-demo-app Cloud Run Service Account"
}

resource "google_storage_bucket_iam_member" "storage_admin" {
  bucket = google_storage_bucket.storage.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  secret_id = google_secret_manager_secret.database_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_cloud_run_v2_service" "web_app" {
  name         = "ci-demo-app"
  location     = var.region
  ingress      = "INGRESS_TRAFFIC_ALL"
  launch_stage = "BETA"

  template {
    service_account = google_service_account.cloud_run_sa.email

    containers {
      image   = "gcr.io/${var.project_id}/ci-demo-app:latest"
      command = ["npm", "start"]

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }

      volume_mounts {
        name       = "storage"
        mount_path = "/data"
      }
    }

    volumes {
      name = "storage"
      gcs {
        bucket    = google_storage_bucket.storage.name
        read_only = false
      }
    }
  }

  depends_on = [
    google_project_service.run,
    google_secret_manager_secret_version.database_url,
  ]
}

resource "google_cloud_run_domain_mapping" "custom_domain" {
  name     = var.domain
  location = var.region

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.web_app.name
  }
}

resource "google_project_service" "cloudbuild" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloudbuild_trigger" "ci_pipeline" {
  name     = "ci-demo-app-ci-pipeline"
  filename = "cloudbuild.yaml"

  github {
    owner = "AppalachianMounta1n"
    name  = "devops-pipeline"
    pull_request {
      branch = "^main$"
    }
    push {
      branch = "^main$"
    }
  }

  depends_on = [google_project_service.cloudbuild]
}

resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}