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
  export AWS_STATE_PRIMARY_REGION="${AWS_STATE_PRIMARY_REGION:-"us-east-1"}"
  export AWS_STATE_SECONDARY_REGION="${AWS_STATE_SECONDARY_REGION:-"us-west-1"}"

  export AWS_STATE_BUCKET_NAME="${AWS_STATE_BUCKET_NAME:-"${APP_NAME}-${__environment}"}"
  export AWS_STATE_KMS_KEY_ID="${AWS_STATE_KMS_KEY_ID:-}"

  export TF_VAR_bucket_name="$AWS_STATE_BUCKET_NAME"
  export TF_VAR_region="$AWS_STATE_PRIMARY_REGION"
  export TF_VAR_replica_region="$AWS_STATE_SECONDARY_REGION"

  if [[ "${AWS_PLATFORM_WRITE_USER:-}" ]] && [[ "${AWS_PLATFORM_WRITE_GROUP:-}" ]]; then
    export TF_VAR_platform_write_user="$AWS_PLATFORM_WRITE_USER"
    export TF_VAR_platform_write_group="$AWS_PLATFORM_WRITE_GROUP"

    if [ -f "${__env_dir}/policy.iam.platform.write.json" ]; then
      export TF_VAR_platform_write_policy="$(envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < "${__env_dir}/policy.iam.platform.write.json")"
    fi
  fi

  if [[ "${AWS_CONTAINER_WRITE_USER:-}" ]] && [[ "${AWS_CONTAINER_WRITE_GROUP:-}" ]]; then
    export TF_VAR_container_write_user="$AWS_CONTAINER_WRITE_USER"
    export TF_VAR_container_write_group="$AWS_CONTAINER_WRITE_GROUP"

    if [ -f "${__env_dir}/policy.iam.container.write.json" ]; then
      export TF_VAR_container_write_policy="$(envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < "${__env_dir}/policy.iam.container.write.json")"
    fi
  fi

  if [[ "${AWS_CONTAINER_READ_USER:-}" ]] && [[ "${AWS_CONTAINER_READ_GROUP:-}" ]]; then
    export TF_VAR_container_read_user="$AWS_CONTAINER_READ_USER"
    export TF_VAR_container_read_group="$AWS_CONTAINER_READ_GROUP"

    if [ -f "${__env_dir}/policy.iam.container.read.json" ]; then
      export TF_VAR_container_read_policy="$(envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < "${__env_dir}/policy.iam.container.read.json")"
    fi
  fi
fi
