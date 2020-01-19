#!/bin/bash -l
set -xeEuo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 REMOTE_URL" >&2
  exit 1
fi


if [[ -n "$SSH_PRIVATE_KEY" ]]
then
  mkdir -p /root/.ssh
  echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
fi

mkdir -p ~/.ssh
cp /root/.ssh/* ~/.ssh/ 2> /dev/null || true 


REMOTE_URL=$1
REMOTE=upstream-$(date +%s)

trap "git remote rm $REMOTE" ERR SIGHUP SIGINT SIGTERM

declare -A EXTRA_ARGS
function join_by { local IFS="$1"; shift; echo "$*"; }

if [[ ${SKIP_HOOKS:-} == "true" ]]; then
  EXTRA_ARGS+="--no-verify"
fi

git remote add $REMOTE $REMOTE_URL
git push $(join_by " " $EXTRA_ARGS) $REMOTE HEAD:master
