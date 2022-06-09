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

  name                        = var.function_app_name
  service_plan_id             = data.azurerm_service_plan.service_plan.id
  resource_group_name         = var.resource_group.name
  location                    = var.resource_group.location
  storage_account_name        = data.azurerm_storage_account.storage_account.name
  storage_account_access_key  = data.azurerm_storage_account.storage_account.primary_access_key

  app_settings                = var.application_settings

  dynamic "connection_string" {
    for_each            = var.connection_strings
    content {
      name              = connection_string.value.name
      type              = connection_string.value.type
      value             = connection_string.value.value
    }
  }

  site_config {

    always_on                 = lookup(var.site_config, "always_on", false)
    api_definition_url        = lookup(var.site_config, "api_definition_url", null)
    api_management_api_id     = lookup(var.site_config, "api_management_api_id", null)
    app_command_line          = lookup(var.site_config, "app_command_line", null)
    app_scale_limit           = lookup(var.site_config, "app_scale_limit", null)
    # auto_swap_slot_name       = lookup(var.site_config, "auto_swap_slot_name", null)
    health_check_path         = lookup(var.site_config, "health_check_path", null)
    http2_enabled             = lookup(var.site_config, "http2_enabled", false)
    pre_warmed_instance_count = lookup(var.site_config, "pre_warmed_instance_count", null)
    scm_minimum_tls_version   = lookup(var.site_config, "scm_minimum_tls_version", "1.2")

    dynamic "cors" {
      for_each              = local.cors
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    application_stack {
      dotnet_version          = local.dotnet_version
      java_version            = local.java_version
      node_version            = local.node_version
      python_version          = local.python_version
      powershell_core_version = local.powershell_version

      dynamic "docker" {
        for_each            = local.is_docker ? toset([data.azurerm_container_registry.acr[0]]) : toset([])
        content {
          registry_url      = "https://${docker.value.login_server}"
          image_name        = var.docker_image_name
          image_tag         = var.docker_image_tag
          registry_username = docker.value.admin_username
          registry_password = docker.value.admin_password
        }
        
      }
    }
    application_insights_connection_string = data.azurerm_application_insights.app_insights.connection_string
    application_insights_key               = data.azurerm_application_insights.app_insights.instrumentation_key
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker[0].image_name,
      site_config[0].application_stack[0].docker[0].image_tag,
      app_settings["WEBSITES_ENABLE_APP_SERVICE_STORAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"]
    ]
  }

  tags = local.tags
}

resource "azurerm_linux_function_app_slot" "main" {

  for_each                    = toset(var.deployment_slots)

  function_app_id             = azurerm_linux_function_app.main.id
  name                        = each.value
  storage_account_name        = data.azurerm_storage_account.storage_account.name
  storage_account_access_key  = data.azurerm_storage_account.storage_account.primary_access_key
  functions_extension_version = azurerm_linux_function_app.main.functions_extension_version
  app_settings                = azurerm_linux_function_app.main.app_settings

  dynamic "connection_string" {
    for_each            = var.connection_strings
    content {
      name              = connection_string.value.name
      type              = connection_string.value.type
      value             = connection_string.value.value
    }
  }

  site_config {

    always_on                 = lookup(var.site_config, "always_on", false)
    api_definition_url        = lookup(var.site_config, "api_definition_url", null)
    api_management_api_id     = lookup(var.site_config, "api_management_api_id", null)
    app_command_line          = lookup(var.site_config, "app_command_line", null)
    app_scale_limit           = lookup(var.site_config, "app_scale_limit", null)
    # auto_swap_slot_name       = lookup(var.site_config, "auto_swap_slot_name", null)
    health_check_path         = lookup(var.site_config, "health_check_path", null)
    http2_enabled             = lookup(var.site_config, "http2_enabled", false)
    pre_warmed_instance_count = lookup(var.site_config, "pre_warmed_instance_count", null)
    scm_minimum_tls_version   = lookup(var.site_config, "scm_minimum_tls_version", "1.2")

    dynamic "cors" {
      for_each              = local.cors
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    application_stack {
      dotnet_version          = local.dotnet_version
      java_version            = local.java_version
      node_version            = local.node_version
      python_version          = local.python_version
      powershell_core_version = local.powershell_version

      dynamic "docker" {
        for_each            = local.is_docker ? toset([data.azurerm_container_registry.acr[0]]) : toset([])
        content {
          registry_url      = "https://${docker.value.login_server}"
          image_name        = var.docker_image_name
          image_tag         = var.docker_image_tag
          registry_username = docker.value.admin_username
          registry_password = docker.value.admin_password
        }
        
      }
    }
    application_insights_connection_string = data.azurerm_application_insights.app_insights.connection_string
    application_insights_key               = data.azurerm_application_insights.app_insights.instrumentation_key
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0].docker[0].image_name,
      site_config[0].application_stack[0].docker[0].image_tag,
      app_settings["WEBSITES_ENABLE_APP_SERVICE_STORAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"]
    ]
  }

  tags                                    = azurerm_linux_function_app.main.tags
}