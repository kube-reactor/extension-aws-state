<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.84.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_remote_state"></a> [remote\_state](#module\_remote\_state) | nozaq/remote-state-s3-backend/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_user.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.remote_state_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The base AWS bucket name for the cluster state. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which resources are set up. | `string` | `"us-east-1"` | no |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | The AWS region to which the state bucket is replicated. | `string` | `"us-west-1"` | no |
| <a name="input_terraform_user"></a> [terraform\_user](#input\_terraform\_user) | The username of the user that provisions infrastructure through Terraform. | `string` | `"TerraformUser"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_table"></a> [dynamodb\_table](#output\_dynamodb\_table) | The DynamoDB table to manage lock states. |
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | The KMS customer master key to encrypt state buckets. |
| <a name="output_kms_key_alias"></a> [kms\_key\_alias](#output\_kms\_key\_alias) | The alias of the KMS customer master key used to encrypt state bucket and dynamodb. |
| <a name="output_kms_key_replica"></a> [kms\_key\_replica](#output\_kms\_key\_replica) | The KMS customer master key to encrypt replica bucket and dynamodb. |
| <a name="output_replica_bucket"></a> [replica\_bucket](#output\_replica\_bucket) | The S3 bucket to replicate the state S3 bucket. |
| <a name="output_state_bucket"></a> [state\_bucket](#output\_state\_bucket) | The S3 bucket to store the remote state file. |
| <a name="output_terraform_iam_policy"></a> [terraform\_iam\_policy](#output\_terraform\_iam\_policy) | The IAM Policy to access remote state environment. |
<!-- END_TF_DOCS -->