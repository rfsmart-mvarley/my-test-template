app_name           = "TEMPLATE-web"
app_image          = "ghcr.io/rf-smart-for-oraclecloud/TEMPLATE-web"
environment        = "phxdev"
namespace          = "phoenix"
route_53_a_record  = "TEMPLATE-api.phxdev.phoenix.rfsmart.com"
route_53_zone_name = "phxdev.phoenix.rfsmart.com"
service_declaration = {
  name = "TEMPLATE"
  type = "api"
}
