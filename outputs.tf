output "api_gw_url" {
  description = "The API Gateway URL to call"
  value       = "${aws_api_gateway_deployment.api_gw_deployment.invoke_url}"
}
