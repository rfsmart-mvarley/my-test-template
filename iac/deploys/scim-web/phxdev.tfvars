app_name           = "scim-web"
app_image          = "ghcr.io/rf-smart-for-oraclecloud/scim-web"
environment        = "phxdev"
namespace          = "phoenix"
route_53_a_record  = "scim-api.phxdev.phoenix.rfsmart.com"
route_53_zone_name = "phxdev.phoenix.rfsmart.com"
service_declaration = {
  name = "scim"
  type = "api"
}
