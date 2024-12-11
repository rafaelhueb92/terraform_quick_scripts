provider "aws" {
  region = "us-east-1" # Adjust to your desired region
}

# Create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
  acl    = "private"

  versioning {
    enabled = true
  }
}

# Define bucket notification
resource "aws_s3_bucket_notification" "my_bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-lambda-function-1" # Replace with your first Lambda ARN
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "exclude/" # Ignore files with this prefix (adjust as needed)
  }

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-lambda-function-2" # Replace with your second Lambda ARN
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".tmp" # Ignore files with this suffix (adjust as needed)
  }

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-lambda-function-1" # First Lambda for update events
    events              = ["s3:ObjectRemoved:*"]
    filter_prefix       = "exclude/" # Adjust for files to exclude
  }

  depends_on = [
    aws_lambda_permission.allow_s3_to_invoke_lambda1,
    aws_lambda_permission.allow_s3_to_invoke_lambda2,
  ]
}

# Grant S3 permission to invoke the first Lambda function
resource "aws_lambda_permission" "allow_s3_to_invoke_lambda1" {
  statement_id  = "AllowExecutionFromS3-1"
  action        = "lambda:InvokeFunction"
  function_name = "my-lambda-function-1" # Replace with your first Lambda name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_bucket.arn
}

# Grant S3 permission to invoke the second Lambda function
resource "aws_lambda_permission" "allow_s3_to_invoke_lambda2" {
  statement_id  = "AllowExecutionFromS3-2"
  action        = "lambda:InvokeFunction"
  function_name = "my-lambda-function-2" # Replace with your second Lambda name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_bucket.arn
}
