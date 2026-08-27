# resource "aws_cloudwatch_log_group" "ghost_bridge_lambda_logs" {
#   name              = "/aws/lambda/ghost-bridge-lambda"
#   retention_in_days = 30

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "ghost-bridge-lambda-logs"
#     }
#   )
# }
