resource_group = {
    name = "deb-test-devops"
    location = "eastus"
}

storage_account = {
    name = "debtest000sa000"
    rg_name = "deb-test-devops"
}

application_insights = {
    name = "demo-eastus-dev-000-appins-000"
    rg_name = "deb-test-devops"
}

service_plan = {
    name = "demo-eastus-dev-000-lsp-000"
    rg_name = "deb-test-devops"
}

container_registry = {
    name = "nexientacr000"
    rg_name = "deb-test-devops"
}

function_app_name = "deb-test-func-000"

deployment_slots = ["stage"]

application_stack = "dotnet"

dotnet_version = "6.0"

application_settings = {
    "APP_VERION" = "6.0"
}

