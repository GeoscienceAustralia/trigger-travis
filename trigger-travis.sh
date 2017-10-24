#!/usr/bin/env bash

# Trigger builds of downstream dependencies.
#
# Usage: declare -a downstream=("project-a" "project-b"); trigger-travis [-b <branch>] "${downstream[@]}"
# Notes:
#   1) In a Travis build job, TRAVIS_PULL_REQUEST is either set to "false" or to the pull request number.
#   2) Use travis CLI to generate and ecrypt the API token TRAVIS_TOKEN.
#   3) Default branch to trigger is master

function trigger-travis {
    branch="master"
    positional=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--branch)
            branch="$2"
            shift
            shift
            ;;
            *)
            positional+=("$1")
            shift
            ;;
        esac
    done

    set -- "${positional[@]}"

    if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
        for repo in "$@"; do
            body='{
            "request": {
              "branch":"'"${branch}"'"
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
