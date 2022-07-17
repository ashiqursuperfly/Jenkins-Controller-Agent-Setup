#!/bin/bash
set -o nounset

JENKINS_CONTAINER_NAME=$1
JENKINS_HOME=`pwd`/jenkins/jenkins_home 
echo "JENKINS HOME: $JENKINS_HOME"

CONTAINER_NAME=$JENKINS_CONTAINER_NAME JENKINS_HOME=$JENKINS_HOME docker-compose -f docker-compose-controller.yaml up --build -d

sleep 10

docker exec $JENKINS_CONTAINER_NAME bash -c "apt-get update -y -q && apt-get upgrade -y -q && apt-get install -y -q git python3 python3-venv"

# docker exec $JENKINS_CONTAINER_NAME bash -c "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\" && unzip awscliv2.zip && ./aws/install"