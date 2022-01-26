#!/bin/bash
#set -x
#
#./add-vault-user.sh -t s.NChugw1IiynKI3q6Zb674U4N -U user-data-call-app -P password -a data-call-app -o AAISOrg -e '"create","update","read"'
#

checkOptions() {
  if [ -z "${VAULT_URL}" ]; then
    echo "VAULT_URL is not defined"
    exit 1
  fi
  if [ -z "${USER_TOKEN}" ]; then
    echo "USER_TOKEN is not defined."
    exit 1
  fi
  if [ -z "${USER_TO_BE_CREATED}" ]; then
    echo "USER_TO_BE_CREATED is not defined."
    exit 1
  fi
  if [ -z "${PASSWORD_TO_BE_CREATED}" ]; then
    echo "PASSWORD_TO_BE_CREATED is not defined."
    exit 1
  fi
  if [ -z "${APP_NAME}" ]; then
    echo "APP_NAME is not defined."
    exit 1
  fi
  if [ -z "${ORG}" ]; then
    echo "ORG is not defined."
    exit 1
  fi
  if [ -z "${PERMISSIONS}" ]; then
    echo "PERMISSIONS is not defined."
    exit 1
  fi
}

addUser() {
  echo "Entering add vault user script()"

  echo "Enable userpass authentication"
  HTTP_STATUS=$(curl --header "X-Vault-Token: ${USER_TOKEN}" \
    --request POST \
    --data '{"type": "userpass"}' \
    ${VAULT_URL}/v1/sys/auth/${ORG} --insecure -s -o /dev/null -w "%{http_code}")
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to execute curl."
    exit 1
  fi
  HTTP_STATUS=${HTTP_STATUS}
  if [ "${HTTP_STATUS}" != "204" ]; then
    echo "Error in Invoking Vault with status ${HTTP_STATUS}."
    exit 1
  fi

  # echo "Enable path for storing config data"
  # HTTP_STATUS=$(curl --header "X-Vault-Token: ${USER_TOKEN}" \
  #   --request POST \
  #   --data '{"type":"kv","options":{"version":2},"generate_signing_key":true}' \
  #   ${VAULT_URL}/v1/sys/mounts/${ORG} --insecure -s -o /dev/null -w "%{http_code}")
  # RESULT=$?
  # if [ $RESULT -ne 0 ]; then
  #   echo "Failed to execute curl."
  #   exit 1
  # fi
  # HTTP_STATUS=${HTTP_STATUS}
  # if [ "${HTTP_STATUS}" != "204" ]; then
  #   echo "Error in Invoking Vault with status ${HTTP_STATUS}."
  #   exit 1
  fi
  
  POLICY_FILE=$(mktemp).json
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to execute mktemp."
    exit 1
  fi
  echo "Create policy file ${POLICY_FILE}."
  PERMISSIONS=$(echo $PERMISSIONS | sed 's/\"/\\\"/g')
  cat >${POLICY_FILE} <<EOF
        {
            "policy": "path \"${ORG}/data/${APP_NAME}/*\" { capabilities = [ ${PERMISSIONS} ]}"
            "policy": "path \"${ORG}/metadata/${APP_NAME}/*\" { capabilities = [ ${PERMISSIONS} ]}"
        }
EOF
  echo "Add policy"
  HTTP_STATUS=$(curl \
    --header "X-Vault-Token: ${USER_TOKEN}" \
    --request PUT \
    --data @${POLICY_FILE} \
    ${VAULT_URL}/v1/sys/policy/${USER_TO_BE_CREATED}-policy --insecure -s -o /dev/null -w "%{http_code}")
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to execute curl."
    exit 1
  fi
  HTTP_STATUS=${HTTP_STATUS}
  if [ "${HTTP_STATUS}" != "204" ]; then
    echo "Error in Invoking Vault with status ${HTTP_STATUS}."
    exit 1
  fi
  rm ${POLICY_FILE}
  POLICY_FILE=$(mktemp).json
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to execute mktemp."
    exit 1
  fi
  echo "Create policy file ${POLICY_FILE}."
  cat >${POLICY_FILE} <<EOF
        {
            "password": "${PASSWORD_TO_BE_CREATED}",
            "policies": "${USER_TO_BE_CREATED}-policy"
        }
EOF
  echo "Create new user"
  HTTP_STATUS=$(curl \
    --header "X-Vault-Token: ${USER_TOKEN}" \
    --request POST \
    --data @${POLICY_FILE} \
    ${VAULT_URL}/v1/auth/${ORG}/users/${USER_TO_BE_CREATED} --insecure -s -o /dev/null -w "%{http_code}")
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to execute curl."
    exit 1
  fi
  HTTP_STATUS=${HTTP_STATUS}
  if [ "${HTTP_STATUS}" != "204" ]; then
    echo "Error in Invoking Vault with status ${HTTP_STATUS}."
    exit 1
  fi
  rm ${POLICY_FILE}
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to remove ${POLICY_FILE}."
    exit 1
  fi

  echo "New user created."
}

VAULT_URL='http://127.0.0.1:8200'
ORG=AAISOrg
USER_TOKEN=""
USER_TO_BE_CREATED=""
PASSWORD_TO_BE_CREATED=""
APP_NAME=""
while getopts "V:t:U:P:a:o:e:" key; do
  case ${key} in
  V)
    VAULT_URL=${OPTARG}
    ;;
  t)
    USER_TOKEN=${OPTARG}
    ;;
  U)
    USER_TO_BE_CREATED=${OPTARG}
    ;;
  P)
    PASSWORD_TO_BE_CREATED=${OPTARG}
    ;;
  a)
    APP_NAME=${OPTARG}
    ;;
  o)
    ORG=${OPTARG}
    ;;
  e)
    PERMISSIONS=${OPTARG}
    ;;
  \?)
    echo "Unknown flag: ${key}"
    ;;
  esac
done

checkOptions
addUser

exit 0
