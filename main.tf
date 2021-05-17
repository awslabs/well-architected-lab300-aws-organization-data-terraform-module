data "archive_file" "organisation_data_zip" {
  type        = "zip"
  source_file = "${path.module}/source/${var.account}organisation_data.py"
  output_path = "${path.module}/source/organisation_data.zip"
}

resource "aws_lambda_function" "organisation_data" {
  filename         = "${path.module}/source/organisation_data.zip"
  function_name    = "${var.function_prefix}Lambda_Org_Data"
  role             = aws_iam_role.iam_role_for_organisation.arn
  handler          = "${var.account}organisation_data.lambda_handler"
  source_code_hash = data.archive_file.organisation_data_zip.output_base64sha256
  runtime          = "python3.6"
  memory_size      = var.memory_size
  timeout          = var.timeout
  environment {
    variables = {
      BUCKET_NAME           = aws_s3_bucket.destination_bucket.id
      TAGS                  = var.tags
      MANAGMENT_ACCOOUNT_ID = var.management_account_id
      REGION                = var.region
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_organisation_data" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.organisation_data.function_name
  principal      = "events.amazonaws.com"
  source_arn     = aws_cloudwatch_event_rule.organisation_data_cloudwatch_rule.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_cloudwatch_event_rule" "organisation_data_cloudwatch_rule" {
  name                = "${var.function_prefix}organisation_data_lambda_trigger"
  schedule_expression = var.organisation_cron
}

resource "aws_cloudwatch_event_target" "organisation_data_lambda" {
  rule      = aws_cloudwatch_event_rule.organisation_data_cloudwatch_rule.name
  target_id = "organisation_data_lambda_target"
  arn       = aws_lambda_function.organisation_data.arn
}

data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket" "destination_bucket" {
  bucket = var.destination_bucket
}