#!/bin/bash
#set -x
#
#./add-vault-config.sh -U user-data-call-app -P password -a data-call-app -o AAISOrg -c ../../openidl-k8s/charts/openidl-secrets/config
#

JQ=$(which jq)
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "Failed to execute jq."
  exit 1
fi
if [ ! -x "${JQ}" ]; then
  echo "jq not found."
  exit 1
fi

checkOptions() {
  if [ -z "${VAULT_URL}" ]; then
    echo "VAULT_URL is not defined"
    exit 1
  fi
  if [ -z "${ORG}" ]; then
    echo "ORG is not defined."
    exit 1
  fi
  if [ -z "${USER_NAME}" ]; then
    echo "USER_NAME is not defined."
    exit 1
  fi
  if [ -z "${PASSWORD}" ]; then
    echo "PASSWORD is not defined."
    exit 1
  fi
  if [ -z "${APP_NAME}" ]; then
    echo "APP_NAME is not defined."
    exit 1
  fi
  if [ -z "${CONFIG_PATH}" ]; then
    echo "CONFIG_PATH is not defined."
    exit 1
  fi
}

addVaultConfig() {
  echo "Entering add vault config script"

  configs=()
  # prepare configs array
  for file in ${CONFIG_PATH}/*; do
    f=$(echo "${file##*/}")
    fileName=$(echo $f | cut -d'.' -f 1) #file has extension, it return only filename
    configs+=($fileName)
  done

  echo "Login to add configuration files"
  LOGIN_RESPONSE=$(curl \
    --request POST \
    --data "{\"password\":\"${PASSWORD}\"}" \
    ${VAULT_URL}/v1/auth/${ORG}/login/${USER_NAME} --insecure)

  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to execute curl."
    exit 1
  fi
  LOGIN_RESPONSE=${LOGIN_RESPONSE}
  USER_TOKEN=$(echo ${LOGIN_RESPONSE} | ${JQ} ".auth.client_token" | sed "s/\"//g")

  for config in "${configs[@]}"; do
    signcerts=$(cat ${CONFIG_PATH}/${config}.json)
    echo ${signcerts}

    JSON_DATA_PAYLOAD="{\"data\":${signcerts}}"
    echo "JSON_DATA_PAYLOAD=${JSON_DATA_PAYLOAD}"
    echo "Add data to vault for ORG=${ORG}, APP_NAME=${APP_NAME}"
    HTTP_STATUS=$(curl \
      --header "X-Vault-Token: ${USER_TOKEN}" \
      --request POST \
      --data "${JSON_DATA_PAYLOAD}" \
      ${VAULT_URL}/v1/${ORG}/data/${APP_NAME}/$config --insecure -s -o /dev/null -w "%{http_code}")
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
      echo "Failed to execute curl."
      exit 1
    fi
    echo "HTTP_STATUS=${HTTP_STATUS}"
    if [ "${HTTP_STATUS}" != "200" ]; then
      echo "API call didn't return 200."
      exit 1
    fi
  done

  echo "All configs have been uploaded successfully."
}

VAULT_URL='http://127.0.0.1:8200'
ORG=AAISOrg
USER_NAME=""
PASSWORD=""
APP_NAME=""
CONFIGPATH=""
while getopts "V:U:P:a:o:c:" key; do
  case ${key} in
  V)
    VAULT_URL=${OPTARG}
    ;;
  U)
    USER_NAME=${OPTARG}
    ;;
  P)
    PASSWORD=${OPTARG}
    ;;
  a)
    APP_NAME=${OPTARG}
    ;;
  o)
    ORG=${OPTARG}
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
addVaultConfig

exit 0
