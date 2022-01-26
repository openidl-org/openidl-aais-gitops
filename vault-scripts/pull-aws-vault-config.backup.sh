#!/bin/bash
#set -x

JQ=$(which jq)
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Failed to execute jq command."
  exit 1
fi
if [ ! -x "${JQ}" ]; then
  echo "jq command not found."
  exit 1
fi
echo "jq is available and working"

checkOptions() {
  if [ -z "${SECRET_ID}" ]; then
    echo "SECRET_ID is not defined"
    exit 1
  fi
  if [ -z "${APP_NAME}" ]; then
    echo "APP_NAME is not defined"
    exit 1
  fi
  if [ -z "${CONFIG_PATH}" ]; then
    echo "CONFIG_PATH is not defined"
    exit 1
  fi
  if [ -z "${AWS_REGION}" ]; then
    echo "AWS_REGION is not defined"
    exit 1
  fi
}

action() {
export AWS_PROFILE=git-role
result=$?
if [ $result -ne 0 ]; then
echo "Failed to set AWS_PROFILE to git-role"
exit 1
fi
echo "AWS_PROFILE is set to git-role successfully"
echo "Retrieve credentials from AWS secret manager"
aws secretsmanager get-secret-value --secret-id ${SECRET_ID} --query SecretString --region ${AWS_REGION} --output text | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]' > /tmp/secrets.env
result=$?
if [ $result -ne 0 ]; then
	echo "Failed to retrieve credentials from AWS secrets manager"
    exit 1
fi
echo "Retrieve credentials from AWS secrets manager is successful"
echo "Exporting AWS credentials as ENV variables"
eval $(cat /tmp/secrets.env | sed 's/^/export /')
result=$?
if [ $result -ne 0 ]; then
	echo "Failed to export credentials as ENV variables"
    exit 1
fi
echo "AWS credentials exporting as ENV variables are successful"
rm -f /tmp/secrets.env
echo "Retrieve data from vault"
./vault/pull-vault-config.sh -V ${url} -U ${username} -P ${password} -a ${APP_NAME} -o ${orgName} -c ${CONFIG_PATH} > pull-vault-config.log
result=$?
if [ $result -ne 0 ]; then
	echo "Failed to retrieve data from VAULT"
    exit 1
fi
echo "Retrieve data from vault is successful"
}
SECRET_ID=""
while getopts "s:a:c:r:" key; do
  case ${key} in
  r)
    AWS_REGION=${OPTARG}
    ;;
  s)
    SECRET_ID=${OPTARG}
    ;;
  a)
    APP_NAME=${OPTARG}
    ;;
  c)
    CONFIG_PATH=${OPTARG}
    ;;
  \?)
    echo "Unknown flag: ${key}"
    ;;
  esac
done

checkOptions
action

exit 0