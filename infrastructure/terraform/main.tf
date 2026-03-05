terraform {
  required_providers {
    render = {
      source  = "render-oss/render"
      version = "1.8.0"
    }
  }
}

provider "render" {
  api_key = var.api_key
  owner_id = var.owner_id
  skip_deploy_after_service_update = false
  wait_for_deploy_completion = true
}

resource "render_web_service" "web_app" {
  name          = "ci-demo-app"
  plan          = "starter"
  region        = "oregon"
  start_command = "npm start"

  runtime_source = {
    native_runtime = {
      auto_deploy   = "true"
      branch        = "main"
      build_command = "npm ci"
      repo_url      = "https://github.com/AppalachianMounta1n/devops-pipeline"
      runtime       = "node"
    }
  }

  disk = {
    name       = "storage"
    size_gb    = 1
    mount_path = "/data"
  }

  env_vars = {
    "DATABASE_URL" = { value = var.database_url }
  }

  custom_domains = [
    { name : var.domain }
  ]
}