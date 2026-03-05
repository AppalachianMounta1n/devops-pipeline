terraform {
  required_providers {
    render = {
        source = "render-oss/render"
        version = "1.8.0"
    }
  }
}

provider "render" {
    api_key = var.api_key
}

resource "render_service" "web_app" {
    name = "ci-demo-app"
    type = "web_service"
    repo = "https://github.com/AppalachianMounta1n/devops-pipeline"
    env = "docker"
    plan = "starter"
    branch = "main"
    build_command = "docker build -t app ."
    start_command = "docker run -p 3000:3000 app"
    auto_deploy = true
}