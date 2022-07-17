#!/bin/bash
set -o nounset

JENKINS_CONTAINER_NAME=$1
JENKINS_AGENT_SSH_PUBKEY=$2

CONTAINER_NAME=$JENKINS_CONTAINER_NAME JENKINS_AGENT_SSH_PUBKEY=$JENKINS_AGENT_SSH_PUBKEY docker-compose -f docker-compose-agent.yaml up --build -d

sleep 10

docker exec $JENKINS_CONTAINER_NAME bash -c "apt-get update -y -q && apt-get upgrade -y -q && apt-get install -y -q git python3 python3-venv"