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

variable "platform_write_user" {
  description = "The username of the user that provisions infrastructure."
  type        = string
  default     = "PlatformDeployer"
}

variable "platform_write_group" {
  description = "The group that contains the policies for provisioning infrastructure."
  type        = string
  default     = "PlatformManagement"
}

variable "platform_write_policy" {
  description = "The AWS IAM policy JSON document to allow the platform provisioning into the AWS environment"
  type        = string
  default     = ""
}

variable "container_write_user" {
  description = "The username of the user that provisions and pulls application container images."
  type        = string
  default     = "ContainerDeployer"
}

variable "container_read_user" {
  description = "The username of the user that pulls application container images."
  type        = string
  default     = "ContainerAccessor"
}
