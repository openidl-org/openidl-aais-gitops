#!/bin/bash
#set -x
#./pull-vault-config.sh -U user-data-call-app -P password -a data-call-app -o AAISOrg -c ./configs
#

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

pullVaultConfig() {
  echo "Entering pullVaultConfig()"

  echo "Login to pull config data"
  LOGIN_RESPONSE=$(curl \
    --request POST \
    --data "{\"password\":\"${PASSWORD}\"}" \
    ${VAULT_URL}/v1/auth/${ORG}/login/${USER_NAME})
  RESULT=$?
  if [ $RESULT -ne 0 ]; then
    echo "Failed to execute curl command."
    exit 1
  fi
  echo LOGIN_RESPONSE=${LOGIN_RESPONSE}
  USER_TOKEN=$(echo ${LOGIN_RESPONSE} | ${JQ} ".auth.client_token" | sed "s/\"//g")

  echo "Pull all configs"

  vaultData="$(curl --header "X-Vault-Token: ${USER_TOKEN}" --request GET ${VAULT_URL}/v1/${ORG}/metadata/${APP_NAME}/?list=true)"
  configKeys=$(echo $vaultData | $JQ ".data.keys[]")

  echo $vaultData | $JQ -c '.data.keys[]' | while read config; do
    config=$(echo "$config" | cut -d'"' -f 2)

    echo ${VAULT_URL}/v1/${ORG}/data/${APP_NAME}/${config}

    HTTP_STATUS=$(curl \
      --header "X-Vault-Token: ${USER_TOKEN}" \
      --request GET \
      ${VAULT_URL}/v1/${ORG}/data/${APP_NAME}/${config})
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
      echo "Failed to execute curl command."
      exit 1
    fi

    CONFIG_DATA=$(echo "${HTTP_STATUS}" | $JQ ".data.data")

    if [ -z "${CONFIG_DATA}" ]; then
      echo "CONFIG_DATA is blank."
      exit 1
    fi

    #Write config files
    echo "${CONFIG_DATA}" >${CONFIG_PATH}/${config}.json
  done

  echo "All configs downloaded completed."

}

VAULT_URL='http://127.0.0.1:8200'
ORG=AAISOrg
USER_NAME=""
PASSWORD=""
APP_NAME=""
CONFIG_PATH=""
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
pullVaultConfig

exit 0
