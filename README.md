### Jenkins Setup

#### Step 1: Spin up a Jenkins Controller(master) Container

Check container logs for the first time admin password and create a new admin user.

#### Step 2: Set up a Jenkins Agent (slave)

1. 
```
ssh-keygen -t rsa -f jenkins_agent_1
```

2. Goto Jenkins Dashboard > Manage Jenkins > Manage Credentials and Add 'System' scoped Credential for enabling SSH into a Jenkins Agent

*System*: Only available on Jenkins server (not visible by jenkins job)
*Global*: Accessible everywhere including jenkins job

Username: jenkins # we want to ssh into the agent as 'jenkins' user which already exists by default in the jenkins-agent container

ID: An Unique ID for the credential that can be used to refer to the credential

Private Key: SSH Private Key file contents

#### Step 3: Spin up a Jenkins Agent(slave) Container

#### Step 4: Configure an Agent from the Jenkins Controller

Goto Jenkins Dashboard > Manage Jenkins > Manage Nodes and Clouds > New Node

Name: JenkinsAgent1

NumberOfExecutors: 1-2

RemoteRootDirectory: /home/jenkins/agent

Usage: Use this node as much as possible

Launch Method: Launch agents via SSH

Host: jenkins_agent # Agent's Hostname or IP to connect. (docker-compose service name) 

Credentials: Select the Credential created in Step 2

HostKeyVerificationStrategy: Non verifying Verification Strategy

Launch Method > Advanced

ConnectionTimeoutInSeconds: 60
MaximumNumberOfRetries: 10
SecondsToWaitBetweenRetries: 15