#output "url" {
#  value = "${module.api_gateway.url}/${module.api_gateway.endpoint_path}"
#}

output "url" {
  value = "${module.api_gateway.url}/"
}
