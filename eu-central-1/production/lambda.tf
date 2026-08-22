resource "aws_lambda_function" "ghost_bridge_lambda" {
  function_name = "ghost-bridge-lambda"
  role          = aws_iam_role.ghost_bridge_lambda_role.arn

  runtime = "python3.12"
  handler = "ghost_bridge.lambda_handler"

  # Lambda deployment package created by CI/CD
  s3_bucket = "munchen-auto-munich"
  s3_key    = "lambda/ghost-bridge.zip"

  timeout     = 60
  memory_size = 512

  architectures = ["x86_64"]

  vpc_config {
    subnet_ids = [
      aws_subnet.ghost_bridge_private_subnet_1.id,
      aws_subnet.ghost_bridge_private_subnet_2.id
    ]

    security_group_ids = [
      aws_security_group.ghost_bridge_lambda_sg.id
    ]
  }

  environment {
    variables = {
      DB_SECRET_ARN = aws_secretsmanager_secret.ghost_bridge_db_secret.arn
    }
  }

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-lambda"
  })
}
