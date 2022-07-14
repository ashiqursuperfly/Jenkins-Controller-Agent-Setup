#!/bin/bash
set -o nounset

JENKINS_AGENT_SSH_PUBKEY=$1
echo $JENKINS_AGENT_SSH_PUBKEY

JENKINS_AGENT_SSH_PUBKEY=$JENKINS_AGENT_SSH_PUBKEY docker-compose -f docker-compose-agent.yaml up --build -d