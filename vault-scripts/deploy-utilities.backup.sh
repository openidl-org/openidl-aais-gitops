#!/bin/bash
#set -x
checkOptions() {
    if [ -z "${ACCESS_ID}" ]; then
        echo "AWS_ACCESS_ID is not defined"
        exit 1
    fi
    if [ -z "${SECRET_KEY}" ]; then
        echo "AWS_SECRET_KEY is not defined"
        exit 1
    fi
    if [ -z "${REGION}" ]; then
        echo "AWS_REGION is not defined"
        exit 1
    fi
    if [ -z "${ROLE}" ]; then
        echo "ROLE is not defined"
        exit 1
    fi
}
action() {
    echo "Install utilities"
    yum install unzip wget tar gzip jq which sed less -y > /dev/null 2&>1
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to install utilities using yum install"
        exit 1
    fi
    echo "Success with yum install for required utilities"
    wget https://get.helm.sh/helm-v3.7.0-rc.3-linux-amd64.tar.gz -o helm_download.log
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to download helm binary"
        exit 1
    fi
    echo "Downloaded helm binary"
    tar -zxvf helm-v3.7.0-rc.3-linux-amd64.tar.gz > /dev/null
    result=$?
    if [ $result -ne 0 ]; then
        echo "Extracting helm binary failed"
        exit 1
    fi
    echo "Helm binary extracted"
    mv linux-amd64/helm /usr/local/bin/helm
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to move helm binary under /usr/local/bin"
        exit 1
    fi
    echo "Helm is ready for usage"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to download awscli"
        exit 1
    fi
    echo "awscli download completed"
    unzip awscliv2.zip > /dev/null
    result=$?
    if [ $result -ne 0 ]; then
        echo "Extract awscli"
        exit 1
    fi
    echo "awscli unzipped"
    ./aws/install
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to install awscli"
        exit 1
    fi
    echo "awscli install completed"
    aws configure set aws_access_key_id ${ACCESS_ID} --profile git-user
    result=$?
    if [ $result -ne 0 ]; then
        echo "AWS access key failed to set on profile git-user"
        exit 1
    fi
    aws configure set aws_secret_access_key ${SECRET_KEY} --profile git-user
    result=$?
    if [ $result -ne 0 ]; then
        echo "AWS secret key failed to set on profile git-user"
        exit 1
    fi
    aws configure set region ${REGION} --profile git-user
    result=$?
    if [ $result -ne 0 ]; then
        echo "AWS region failed to set on profiel git-user"
        exit 1
    fi
    aws configure set external_id ${EXTERNAL_ID} --profile git-user
    result=$?
    if [ $result -ne 0 ]; then
        echo "AWS external_id failed to set on profile git-user"
        exit 1
    fi
    aws configure set external_id ${EXTERNAL_ID} --profile git-role
    result=$?
    if [ $result -ne 0 ]; then
        echo "AWS external_id failed to set on profile git-role"
        exit 1
    fi
    aws configure set source_profile git-user --profile git-role
    result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to set source_profile as git-user on profile git-role"
        exit 1
    fi
    aws configure set role_arn ${ROLE} --profile git-role
    result=$?
    if [ $result -ne 0 ]; then
        echo "AWS role failed to set"
        exit 1
    fi
    echo "All AWS environment variables set successfully"
}
SECRET_KEY=""
ACCESS_ID=""
REGION=""
ROLE=""
EXTERNAL_ID="git-actions"

while getopts "a:s:r:o:" key; do
    case ${key} in
        a)
            ACCESS_ID=${OPTARG}
        ;;
        s)
            SECRET_KEY=${OPTARG}
        ;;
        r)
            REGION=${OPTARG}
        ;;
        o)
            ROLE=${OPTARG}
        ;;
        \?)
            echo "Unknown flag: ${key}"
        ;;
    esac
done

checkOptions
action

exit 0
