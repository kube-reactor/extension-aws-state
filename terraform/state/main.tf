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

resource "aws_iam_user" "terraform" {
  name = var.terraform_user
}

resource "aws_iam_group" "provisioner" {
  name = var.terraform_group
  path = "/provisioner/"
}

resource "aws_iam_group_membership" "provisioners" {
  name  = "terraform-provisioner-group"
  group = aws_iam_group.provisioner.name
  users = [
    aws_iam_user.terraform.name,
  ]
}

resource "aws_iam_group_policy" "management_permissions" {
  count  = var.terraform_policy == "" ? 0 : 1
  name   = "TerraformManagementPolicy"
  policy = var.terraform_policy
  group  = aws_iam_group.provisioner.name
}

resource "aws_iam_group_policy_attachment" "remote_state_access" {
  group      = aws_iam_group.provisioner.name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}
