
function ensure_remote_state_aws_s3 () {
  if [ ! "$AWS_STATE_KMS_KEY_ID" ]; then
    provisioner_create state "${__aws_state_project_dir}"
    sed -i -e \
      "s/AWS_STATE_KMS_KEY_ID\=\"\"/AWS_STATE_KMS_KEY_ID\=\"$(jq -r ".kms_key.value" "${__env_dir}/state.json")\"/" \
      "${__env_dir}/secret.sh"
  fi
}

function destroy_remote_state_aws_s3 () {
  if [ "$AWS_STATE_KMS_KEY_ID" ]; then
    provisioner_destroy state "${__aws_state_project_dir}"
    sed -i -e \
      "s/AWS_STATE_KMS_KEY_ID\=\"${AWS_STATE_KMS_KEY_ID}\"/AWS_STATE_KMS_KEY_ID\=\"\"/" \
      "${__env_dir}/secret.sh"
  fi
}

function get_remote_state_aws_s3 () {
  local options=(
    "-backend-config="bucket=${AWS_STATE_BUCKET_NAME}""
    "-backend-config="kms_key_id=${AWS_STATE_KMS_KEY_ID}""
    "-backend-config="dynamodb_table=${AWS_STATE_BUCKET_NAME}""
    "-backend-config="region=${AWS_STATE_PRIMARY_REGION}""
  )
  echo "${options[@]}"
}
