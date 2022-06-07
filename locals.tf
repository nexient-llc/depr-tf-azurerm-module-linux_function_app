locals {
    is_docker = var.application_stack == "docker" ? true : false
    default_tags = {
        "provisioner" : "Terraform"
    }
    tags = merge(local.default_tags, var.custom_tags)
}