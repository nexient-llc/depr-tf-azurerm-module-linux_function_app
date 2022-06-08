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

connection_strings = [
    {
        name = "test_sql"
        type = "SQLServer"
        value = "jdbc:sqlserver://sql-wus-dev.database.windows.net:1433;database=sqldbwusdev;user=db_admin@sql-wus-dev;password={your_password_here};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
    }
]

cors = {
    allowed_origins = ["example.com", "vanillavc.com"]
    support_credentials = false
}

site_config = {
    "always_on" = true
}