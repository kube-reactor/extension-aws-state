#
#=========================================================================================
# Initialization
#
#
# Project Directories
#
export __aws_state_extension_dir="${2}"
export __aws_state_terraform_dir="${__aws_state_extension_dir}/terraform"

export __aws_state_project_dir="${__aws_state_terraform_dir}/state"
export __terraform_state_file="${__aws_state_terraform_dir}/state.tf"

if [ "${STATE_PROVIDER:-}" == "aws_s3" ]; then
  #
  # AWS
  #
  export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
  export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"

  if [[ ! "$AWS_ACCESS_KEY_ID" ]] || [[ ! "$AWS_SECRET_ACCESS_KEY" ]]; then
    emergency "To provision AWS resources, you must specify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables"
  fi

  export AWS_STATE_PRIMARY_REGION="${AWS_STATE_PRIMARY_REGION:-"us-east-1"}"
  export AWS_STATE_SECONDARY_REGION="${AWS_STATE_SECONDARY_REGION:-"us-west-1"}"

  export AWS_STATE_BUCKET_NAME="${AWS_STATE_BUCKET_NAME:-"${APP_NAME}-${__environment}"}"
  export AWS_STATE_KMS_KEY_ID="${AWS_STATE_KMS_KEY_ID:-}"
  #
  # State
  #
  export TF_VAR_bucket_name="$AWS_STATE_BUCKET_NAME"
  export TF_VAR_region="$AWS_STATE_PRIMARY_REGION"
  export TF_VAR_replica_region="$AWS_STATE_SECONDARY_REGION"

  export TF_VAR_terraform_user="$AWS_TERRAFORM_USER"
fi
