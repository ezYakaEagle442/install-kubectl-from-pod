#!/usr/bin/env bash
set -eEuo pipefail

# https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners#adding-a-self-hosted-runner-to-a-repository
# Running the config script to configure the self-hosted runner application and register it with GitHub Actions. 
# The config script requires the destination URL and an automatically-generated time-limited token to authenticate the request.
# https://docs.github.com/rest/reference/actions#create-a-registration-token-for-a-repository
REG_TOKEN=$(curl -s -X POST -H "authorization: token ${GHA_RUNNER_PAT}" "https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token" | jq -r .token)

cleanup() {
  ./config.sh remove --token "${REG_TOKEN}"
}

./config.sh \
  --url "https://github.com/${OWNER}/${REPO}" \
  --token "${REG_TOKEN}" \
  --name "${NAME}" \
  --unattended \
  --work _work

./run.sh

cleanup