data "aws_s3_bucket" "munchen_auto" {
  bucket = "munchen-auto-munich"
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ghost_bridge_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.munchen_auto.arn
}

resource "aws_s3_bucket_notification" "munchen_auto_notification" {
  bucket = data.aws_s3_bucket.munchen_auto.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ghost_bridge_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".parquet"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}
