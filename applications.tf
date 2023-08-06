data "azuread_client_config" "current" {}

# This will be allowed to get secret from KV
resource "azuread_application" "aad-app1" {
  display_name = var.project 
}

resource "azuread_application_password" "aad-app1" {
  display_name = join("-", ["tf", var.project])
  application_object_id = azuread_application.aad-app1.object_id
}
