locals {
    is_docker = var.application_stack == "docker" ? true : false
    default_tags = {
        "provisioner" : "Terraform"
    }
    tags = merge(local.default_tags, var.custom_tags)

    dotnet_version = var.application_stack == "dotnet" ? var.dotnet_version : null
    java_version = var.application_stack == "java" ? var.java_version : null
    node_version = var.application_stack == "node" ? var.node_version : null
    python_version = var.application_stack == "python" ? var.python_version : null
    powershell_version = var.application_stack == "powershell" ? var.powershell_version : null

    cors = var.cors != null ? toset([var.cors]) : toset([])
}