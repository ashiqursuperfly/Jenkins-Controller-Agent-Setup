#!/bin/bash

JENKINS_HOME=`pwd`/jenkins/jenkins_home 
echo "JENKINS HOME: $JENKINS_HOME"

JENKINS_HOME=$JENKINS_HOME docker-compose -f docker-compose-controller.yaml up --build -d