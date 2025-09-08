output "data_bucket_name" { value = aws_s3_bucket.data.bucket }
output "api_base_url" { value = aws_apigatewayv2_api.http.api_endpoint }
output "status_route" { value = "/status" }
output "schedule" { value = var.schedule_expression }