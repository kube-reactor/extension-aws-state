variable "bucket_name" {
  description = "The base AWS bucket name for the cluster state."
  type        = string
}

variable "region" {
  description = "The AWS region in which resources are set up."
  type        = string
  default     = "us-east-1"
}

variable "replica_region" {
  description = "The AWS region to which the state bucket is replicated."
  type        = string
  default     = "us-west-1"
}

variable "terraform_user" {
  description = "The username of the user that provisions infrastructure through Terraform."
  type        = string
  default     = "TerraformUser"
}

variable "terraform_group" {
  description = "The group that contains the policies for provisioning infrastructure through Terraform."
  type        = string
  default     = "TerraformGroup"
}

variable "terraform_policy" {
  description = "The AWS IAM policy JSON document to allow the Terraform provisioning into the AWS environment"
  type        = string
  default     = ""
}
