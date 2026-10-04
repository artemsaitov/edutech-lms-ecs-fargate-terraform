output "github_actions_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions through OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN"
  value       = data.aws_iam_openid_connect_provider.github.arn
}