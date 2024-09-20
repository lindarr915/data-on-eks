output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.name}"
}
output "grafana_secret_name" {
  description = "The name of the secret containing the Grafana admin password."
  value       = aws_secretsmanager_secret.grafana.name
}
output "model_s3_bucket" {
  description = "The S3 bucket name for storing ML models"
  value       = length(aws_s3_bucket.model_storage) > 0 ? aws_s3_bucket.model_storage[0].bucket : ""
}
