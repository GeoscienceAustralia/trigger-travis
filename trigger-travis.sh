#!/usr/bin/env bash

# Trigger builds of downstream dependencies.
#
# Usage: declare -a downstream=("project-a" "project-b"); trigger-travis "${downstream[@]}"
# Notes:
#   1) In a Travis build job, TRAVIS_PULL_REQUEST is either set to "false" or to the pull request number.
#   2) Use travis CLI to generate and ecrypt the API token TRAVIS_TOKEN.
function trigger-travis {
    if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
        for repo in "$@"; do
            body='{
            "request": {
              "branch":"master"
            }}'

            curl -s -X POST \
              -H "Content-Type: application/json" \
              -H "Accept: application/json" \
              -H "Travis-API-Version: 3" \
              -H "Authorization: token ${TRAVIS_TOKEN}" \
              -d "${body}" \
              https://api.travis-ci.org/repo/GeoscienceAustralia%2F"${repo}"/requests
        done
    fi
}
