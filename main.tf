data "azurerm_application_insights" "app_insights" {
  name                = var.application_insights.name
  resource_group_name = var.application_insights.rg_name
}

data "azurerm_container_registry" "acr" {
  count = local.is_docker ? 1 : 0

  name                = var.container_registry.name
  resource_group_name = var.container_registry.rg_name
}

data "azurerm_storage_account" "storage_account" {
  name                = var.storage_account.name
  resource_group_name = var.storage_account.rg_name
} 

data "azurerm_service_plan" "service_plan" {
  name                = var.service_plan.name
  resource_group_name = var.service_plan.rg_name
}

resource "azurerm_linux_function_app" "main" {

  service_plan_id = data.azurerm_service_plan.service_plan.id

  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  storage_account_name       = data.azurerm_storage_account.storage_account.name
  storage_account_access_key = data.azurerm_storage_account.storage_account.primary_access_key

  name                        = var.function_app_name

  site_config {
    application_stack {
      # dotnet_version = var.function_app.dotnet_version
      # This block is required for the function to be hosted on containers.
      dynamic "docker" {
        for_each = local.is_docker ? toset([data.azurerm_container_registry.acr[0]]) : toset([])
        content {
          registry_url = "https://${docker.value.login_server}"
          image_name = "sample-functions"
          image_tag = "1001"
          registry_username = docker.value.admin_username
          registry_password = docker.value.admin_password
        }
        
      }
    }
    application_insights_connection_string = data.azurerm_application_insights.app_insights.connection_string
    application_insights_key               = data.azurerm_application_insights.app_insights.instrumentation_key

    
  }

  tags = local.tags
  #key_vault_reference_identity_id = var.identity.key_vault_reference_identity_id

  # identity {
  #   type         = var.identity.type
  #   identity_ids = var.identity.identity_ids
  # }
}

resource "azurerm_linux_function_app_slot" "main" {

  for_each = toset(var.deployment_slots)

  function_app_id = azurerm_linux_function_app.main.id

  storage_account_name       = data.azurerm_storage_account.storage_account.name
  storage_account_access_key = data.azurerm_storage_account.storage_account.primary_access_key

  name                        = each.value
  functions_extension_version = azurerm_linux_function_app.main.functions_extension_version

  site_config {
    application_stack {
      # dotnet_version = var.function_app.dotnet_version
      # This block is required for the function to be hosted on containers.
      dynamic "docker" {
        for_each = local.is_docker ? toset([data.azurerm_container_registry.acr[0]]) : toset([])
        content {
          registry_url = "https://${docker.value.login_server}"
          image_name = "sample-functions"
          image_tag = "1001"
          registry_username = docker.value.admin_username
          registry_password = docker.value.admin_password
        }
        
      }
    }
    application_insights_connection_string = data.azurerm_application_insights.app_insights.connection_string
    application_insights_key               = data.azurerm_application_insights.app_insights.instrumentation_key

    
  }
}