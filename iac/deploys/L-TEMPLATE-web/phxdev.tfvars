app_name           = "L-TEMPLATE-web"
app_image          = "ghcr.io/rf-smart-for-oraclecloud/L-TEMPLATE-web"
environment        = "phxdev"
namespace          = "phoenix"
route_53_a_record  = "L-TEMPLATE-api.phxdev.phoenix.rfsmart.com"
route_53_zone_name = "phxdev.phoenix.rfsmart.com"
service_declaration = {
  name = "L-TEMPLATE"
  type = "api"
}
