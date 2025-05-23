module "remote_state" {
  source                             = "nozaq/remote-state-s3-backend/aws"
  version                            = "1.6.1"
  override_s3_bucket_name            = true
  s3_bucket_name                     = var.bucket_name
  s3_bucket_name_replica             = "${var.bucket_name}-replica"
  override_terraform_iam_policy_name = true
  terraform_iam_policy_name          = "TerraformStateAccessPolicy"
  kms_key_alias                      = var.bucket_name
  dynamodb_table_name                = var.bucket_name

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

resource "aws_iam_user" "platform_writer" {
  name = var.platform_write_user
}

resource "aws_iam_group" "platform_writer" {
  name = var.platform_write_group
  path = "/platform/"
}

resource "aws_iam_group_membership" "platform_writer" {
  name  = "platform-group"
  group = aws_iam_group.platform_writer.name
  users = [
    aws_iam_user.platform_writer.name,
  ]
}

resource "aws_iam_group_policy" "platform_writer" {
  count  = var.platform_write_policy == "" ? 0 : 1
  name   = "PlatformManagementPolicy"
  policy = var.platform_write_policy
  group  = aws_iam_group.platform_writer.name
}

resource "aws_iam_group_policy_attachment" "platform_writer_state_access" {
  group      = aws_iam_group.platform_writer.name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}

resource "aws_iam_user" "container_writer" {
  name = var.container_write_user
}

resource "aws_iam_user" "container_reader" {
  name = var.container_read_user
}
