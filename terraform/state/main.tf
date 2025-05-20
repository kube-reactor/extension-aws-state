module "remote_state" {
  source                  = "nozaq/remote-state-s3-backend/aws"
  version                 = "1.6.1"
  override_s3_bucket_name = true
  s3_bucket_name          = var.bucket_name
  s3_bucket_name_replica  = "${var.bucket_name}-replica"
  kms_key_alias           = var.bucket_name
  dynamodb_table_name     = var.bucket_name

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

resource "aws_iam_user" "terraform" {
  name = var.terraform_user
}

resource "aws_iam_user_policy_attachment" "remote_state_access" {
  user       = aws_iam_user.terraform.name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}
