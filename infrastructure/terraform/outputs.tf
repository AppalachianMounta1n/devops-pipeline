output "service_url" {
  description = "Default Cloud Run HTTPS URL"
  value       = google_cloud_run_v2_service.web_app.uri
}

output "custom_domain" {
  description = "Custom domain mapped to the service"
  value       = var.domain
}

output "storage_bucket" {
  description = "GCS bucket name backing the /data volume"
  value       = google_storage_bucket.storage.name
}