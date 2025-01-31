
function aws_state_environment () {
  if [ "${__project_dir:-}" ]; then
    debug "Setting AWS environment ..."
    export AWS_STATE_PRIMARY_REGION="${AWS_STATE_PRIMARY_REGION:-"us-east-1"}"
    export AWS_STATE_SECONDARY_REGION="${AWS_STATE_SECONDARY_REGION:-"us-west-1"}"
    export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
    export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"

    export AWS_STATE_BUCKET_NAME="${AWS_STATE_BUCKET_NAME:-"${APP_NAME}-${__environment}"}"
    export AWS_STATE_KMS_KEY_ID="${AWS_STATE_KMS_KEY_ID:-}"

    debug "AWS_STATE_PRIMARY_REGION: ${AWS_STATE_PRIMARY_REGION}"
    debug "AWS_STATE_SECONDARY_REGION: ${AWS_STATE_SECONDARY_REGION}"
    debug "AWS_STATE_BUCKET_NAME: ${AWS_STATE_BUCKET_NAME}"

    if [[ ! "$AWS_ACCESS_KEY_ID" ]] || [[ ! "$AWS_SECRET_ACCESS_KEY" ]]; then
      emergency "To provision AWS resources, you must specify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables"
    fi
  fi
}

function ensure_remote_state_aws_s3 () {
  aws_state_environment

  if [ ! "$AWS_STATE_KMS_KEY_ID" ]; then
    export TF_VAR_bucket_name="$AWS_STATE_BUCKET_NAME"
    export TF_VAR_region="$AWS_STATE_PRIMARY_REGION"
    export TF_VAR_replica_region="$AWS_STATE_SECONDARY_REGION"

    load_hook aws_variables

    if [ ! "${__aws_state_project_dir}" ]; then
      emergency "In order to provision Terraform remote state on AWS you must specify the '__aws_state_project_dir' environment variable in the project to map to a Terraform module"
    fi

    info "Deploying Terraform Remote State ..."
    run_provisioner "${__aws_state_project_dir}" state

    export AWS_STATE_KMS_KEY_ID="$(jq -r ".kms_key.value" "${__env_dir}/state.json")"

    run_hook aws_eks_state

    sed -i -e \
      "s/AWS_STATE_KMS_KEY_ID\=\"\"/AWS_STATE_KMS_KEY_ID\=\"${AWS_STATE_KMS_KEY_ID}\"/" \
      "${__env_dir}/secret.sh"
  fi
}

function destroy_remote_state_aws_s3 () {
  aws_state_environment

  if [ "$AWS_STATE_KMS_KEY_ID" ]; then
    export TF_VAR_bucket_name="$AWS_STATE_BUCKET_NAME"
    export TF_VAR_region="$AWS_STATE_PRIMARY_REGION"
    export TF_VAR_replica_region="$AWS_STATE_SECONDARY_REGION"

    load_hook aws_variables

    if [ ! "${__aws_state_project_dir}" ]; then
      emergency "In order to de-provision Terraform remote state on AWS you must specify the '__aws_state_project_dir' environment variable in the project to map to a Terraform module"
    fi

    info "Destroying Terraform Remote State ..."
    run_provisioner_destroy "${__aws_state_project_dir}" state

    run_hook aws_eks_state_destroy

    sed -i -e \
      "s/AWS_STATE_KMS_KEY_ID\=\"${AWS_STATE_KMS_KEY_ID}\"/AWS_STATE_KMS_KEY_ID\=\"\"/" \
      "${__env_dir}/secret.sh"
  fi
}

function get_remote_state_aws_s3 () {
  aws_state_environment

  local options=(
    "-backend-config="bucket=${AWS_STATE_BUCKET_NAME}""
    "-backend-config="kms_key_id=${AWS_STATE_KMS_KEY_ID}""
    "-backend-config="dynamodb_table=${AWS_STATE_BUCKET_NAME}""
    "-backend-config="region=${AWS_STATE_PRIMARY_REGION}""
  )
  echo "${options[@]}"
}
