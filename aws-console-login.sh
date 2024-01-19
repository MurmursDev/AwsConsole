#!/usr/bin/env bash
set -e

roleArn=${1?"Usage: $0 <role-arn> <role-session-name> <profile>"}
roleSessionName=${2?"Usage: $0 <role-arn> <role-session-name> <profile> <region>"}
profile=${3:-default}
region=${4:-us-east-2}

assumeRoleResult=$(aws sts assume-role --role-arn ${roleArn} --role-session-name ${roleSessionName} --profile ${profile} --region ${region} --output text --no-cli-pager )
stsAccessKeyId=$(echo $assumeRoleResult | awk '{print $5}')
stsSecretAccessKey=$(echo $assumeRoleResult | awk '{print $7}')
stsSessionToken=$(echo $assumeRoleResult | awk '{print $8}')

signinTokenResult=$(curl -s --get https://${region}.signin.aws.amazon.com/federation \
  --data-urlencode "Action=getSigninToken" \
  --data-urlencode "SessionDuration=3600" \
  --data-urlencode "Session={\"sessionId\":\"${stsAccessKeyId}\",\"sessionKey\":\"${stsSecretAccessKey}\",\"sessionToken\":\"${stsSessionToken}\"}")

signinToken=$(echo $signinTokenResult | cut  -d '"' -f 4)

echo "https://signin.aws.amazon.com/federation?Action=login&Issuer=AwsConsoleScript&Destination=https%3A%2F%2F${region}.console.aws.amazon.com%2F&SigninToken=${signinToken}"
