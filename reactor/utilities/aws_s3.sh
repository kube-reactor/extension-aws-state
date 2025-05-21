
function check_aws_state_credentials () {
  if [[ ! "${AWS_STATE_ACCESS_KEY_ID:-}" ]] || [[ ! "${AWS_STATE_SECRET_ACCESS_KEY:-}" ]]; then
    emergency "To provision AWS Terraform state, you must specify AWS_STATE_ACCESS_KEY_ID and AWS_STATE_SECRET_ACCESS_KEY environment variables"
  fi
}

function check_aws_credentials () {
  if [[ ! "${AWS_ACCESS_KEY_ID:-}" ]] || [[ ! "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    emergency "To provision or access AWS services, you must specify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables for AWS IAM user: ${AWS_TERRAFORM_USER}"
  fi
}

function ensure_remote_state_aws_s3 () {
  check_aws_state_credentials

  local aws_access_key_id="${AWS_ACCESS_KEY_ID:-}"
  local aws_secret_access_key="${AWS_SECRET_ACCESS_KEY:-}"

  export AWS_ACCESS_KEY_ID="$AWS_STATE_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$AWS_STATE_SECRET_ACCESS_KEY"

  if [[ "${REACTOR_FORCE_STATE_UPDATE:-}" ]] || [[ ! "$AWS_STATE_KMS_KEY_ID" ]]; then
    provisioner_create state "${__aws_state_project_dir}" local

    export AWS_STATE_KMS_KEY_ID="$(jq -r ".kms_key.value" "${__env_dir}/state.output.json")"
    sed -i -e \
      "s/AWS_STATE_KMS_KEY_ID\=\"\"/AWS_STATE_KMS_KEY_ID\=\"${AWS_STATE_KMS_KEY_ID}\"/" \
      "${__env_dir}/secret.sh"
  fi

  if [ ! -f "${__env_dir}/container.write.json" ]; then
    aws iam create-access-key --user-name "$AWS_CONTAINER_WRITE_USER" >"${__env_dir}/container.write.json"
  fi
  if [ ! -f "${__env_dir}/container.read.json" ]; then
    aws iam create-access-key --user-name "$AWS_CONTAINER_READ_USER" >"${__env_dir}/container.read.json"
  fi

  if [[ ! "$aws_access_key_id" ]] || [[ ! "$aws_secret_access_key" ]]; then
    if [ ! -f "${__env_dir}/platform.write.json" ]; then
       aws iam create-access-key --user-name "$AWS_PLATFORM_WRITE_USER" >"${__env_dir}/platform.write.json"
    fi

    export AWS_ACCESS_KEY_ID="$(jq -r ".AccessKey.AccessKeyId" "${__env_dir}/platform.write.json")"
    sed -i -E -e \
      "s?AWS_ACCESS_KEY_ID\=\"[^\"]*\"?AWS_ACCESS_KEY_ID\=\"${AWS_ACCESS_KEY_ID}\"?" \
      "${__env_dir}/secret.sh"

    export AWS_SECRET_ACCESS_KEY="$(jq -r ".AccessKey.SecretAccessKey" "${__env_dir}/platform.write.json")"
    sed -i -E -e \
      "s?AWS_SECRET_ACCESS_KEY\=\"[^\"]*\"?AWS_SECRET_ACCESS_KEY\=\"${AWS_SECRET_ACCESS_KEY}\"?" \
      "${__env_dir}/secret.sh"
  else
    export AWS_ACCESS_KEY_ID="$aws_access_key_id"
    export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
  fi
  check_aws_credentials
}

function destroy_remote_state_aws_s3 () {
  check_aws_state_credentials

  export AWS_ACCESS_KEY_ID="$AWS_STATE_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$AWS_STATE_SECRET_ACCESS_KEY"

  if [[ "${REACTOR_FORCE_STATE_UPDATE:-}" ]] || [[ "$AWS_STATE_KMS_KEY_ID" ]]; then
    for access_key_id in $(aws iam list-access-keys --user-name "$AWS_TERRAFORM_USER" --query "AccessKeyMetadata[].AccessKeyId" --output "text"); do
      aws iam delete-access-key --user-name "$AWS_TERRAFORM_USER" --access-key-id "$access_key_id"
    done
    provisioner_destroy state "${__aws_state_project_dir}" local
    rm -f "${__env_dir}/platform.write.json"
    rm -f "${__env_dir}/container.write.json"
    rm -f "${__env_dir}/container.read.json"

    unset AWS_STATE_KMS_KEY_ID
    sed -i -E -e \
      "s/AWS_STATE_KMS_KEY_ID\=\"[^\"]+\"/AWS_STATE_KMS_KEY_ID\=\"\"/" \
      "${__env_dir}/secret.sh"

    sed -i -E -e \
      "s?AWS_ACCESS_KEY_ID\=\"[^\"]+\"?AWS_ACCESS_KEY_ID\=\"\"?" \
      "${__env_dir}/secret.sh"

    sed -i -E -e \
      "s?AWS_SECRET_ACCESS_KEY\=\"[^\"]+\"?AWS_SECRET_ACCESS_KEY\=\"\"?" \
      "${__env_dir}/secret.sh"
  fi

  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
}

function get_remote_state_aws_s3 () {
  local project_type="$1"
  local options=(
    "-backend-config="bucket=${AWS_STATE_BUCKET_NAME}""
    "-backend-config="kms_key_id=${AWS_STATE_KMS_KEY_ID}""
    "-backend-config="dynamodb_table=${AWS_STATE_BUCKET_NAME}""
    "-backend-config="region=${AWS_STATE_PRIMARY_REGION}""
    "-backend-config="key="${project_type}/terraform.tfstate"""
    "-backend-config="encrypt=true""
  )
  echo "${options[@]}"
}
