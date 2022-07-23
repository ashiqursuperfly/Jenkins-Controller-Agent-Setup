### Setup
#### Step 1: Spin up a Jenkins Controller(master) Container
We can use the official jenkins docker container. Here's an example docker-compose file that you can use.
```yaml
version: '3.8'

services:
  jenkins_controller:
    image: jenkins/jenkins:lts-jdk11
    privileged: true
    user: root
    container_name: $CONTAINER_NAME
    ports:
      - 50001:8080
      - 50002:50000
    volumes:
      - $JENKINS_HOME:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
```
Now, we need to spin up the container and we need to install the required tools for the Jenkins controller node. We can write a simple bash script to achieve that.
```bash
#!/bin/bash
set -o nounset

JENKINS_CONTAINER_NAME=$1
JENKINS_HOME=`pwd`/jenkins/jenkins_home 
echo "JENKINS HOME: $JENKINS_HOME"

CONTAINER_NAME=$JENKINS_CONTAINER_NAME JENKINS_HOME=$JENKINS_HOME docker-compose -f docker-compose-controller.yaml up --build -d

sleep 10

# Here we have just installed git for our controller node, install as many tools as you require
docker exec $JENKINS_CONTAINER_NAME bash -c "apt-get update -y -q && apt-get upgrade -y -q && apt-get install -y -q git"
```
- Jenkins uses apache jetty which uses port 8080 by default, We mapped our host machine's port 50001 with the container's 8080. So, entering http://host:50001 should take you to the Jenkins web dashboard.
- Check container logs for the first time admin password and create a new admin user. 

#### Step 2: Set up a Jenkins Agent (slave)
We can now setup our agent(s). Since, our Jenkins controller will communicate with the agents using SSH, we need to generate the SSH keys. In this case, the Jenkins master node will act as the SSH client and the agent(s) will act as SSH servers. So, we need to set it up accordingly.

1. Generate Keys 
```
ssh-keygen -t rsa -f jenkins_agent_1
```
2. Goto *Jenkins Dashboard* > *Manage Jenkins* > *Manage Credentials* > Add 'System' scoped Credential for enabling SSH into a Jenkins Agent

*System Credential vs Global Credential*
*System*: Only available on Jenkins server (not visible by jenkins job)
*Global*: Accessible everywhere including jenkins job

**Fill up the form with the appropriate values. Here's an example,**
*Username*: jenkins # we want to ssh into the agent as 'jenkins' user which already exists by default in the jenkins-agent container we will be using

*ID*: An Unique ID for the credential that can be used to refer to the credential

*Private Key*: SSH Private Key file contents (e.g: jenkins_agent_1.pub)

#### Step 3: Spin up a Jenkins Agent(slave) Container
We can use the official jenkins-ssh-agent docker container. Here's an example docker-compose file that you can use.
```yaml
version: '3.8'

services:
  jenkins_agent:
    image: jenkins/ssh-agent:jdk11
    privileged: true
    user: root
    container_name: $CONTAINER_NAME
    expose:
      - 22
    environment:
      - JENKINS_AGENT_SSH_PUBKEY=$JENKINS_AGENT_SSH_PUBKEY
```
Notice that, we must set the environment variable `JENKINS_AGENT_SSH_PUBKEY` which in this case we are doing from a bash variable. We also need to install the required tools in our Jenkins agent. We can achieve all that using a simple bash script like the one below,
```bash
#!/bin/bash
set -o nounset

JENKINS_CONTAINER_NAME=$1
JENKINS_AGENT_SSH_PUBKEY=$2

CONTAINER_NAME=$JENKINS_CONTAINER_NAME JENKINS_AGENT_SSH_PUBKEY=$JENKINS_AGENT_SSH_PUBKEY docker-compose -f docker-compose-agent.yaml up --build -d

sleep 10

# Here we have just installed tools that help us create a python virtual environment for our agent node, install as many tools as you require
docker exec $JENKINS_CONTAINER_NAME bash -c "apt-get update -y -q && apt-get upgrade -y -q && apt-get install -y -q git python3 python3-venv"
```
#### Step 4: Configure an Agent from the Jenkins Controller

Goto *Jenkins Dashboard* > *Manage Jenkins* > *Manage Nodes and Clouds* > *New Node*

**Fill up the form using the appropriate values. Here's an example,**
*Name*: JenkinsAgent1

*NumberOfExecutors*: 1-2

*RemoteRootDirectory*: /home/jenkins/agent

*Labels*: linux, python # Space separated values, Can be useful to restrict jobs to run on a particular agent

*Usage*: Use this node as much as possible

*Launch Method*: Launch agents via SSH

*Host*: jenkins_agent # Agent's Hostname or IP to connect. (docker-compose service name if controller and agent is on the same machine) 

*Credentials*: Select the Credential created in Step 2.1

*HostKeyVerificationStrategy*: Non verifying Verification Strategy

Launch Method > Advanced

*ConnectionTimeoutInSeconds*: 60
*MaximumNumberOfRetries*: 10
*SecondsToWaitBetweenRetries*: 15

There are some other options you might wanna look into, but the ones i discussed should help you get started. 

We can create as many agents as we require using the process discussed above.

#### Step 5: Create jobs and run
Now, our agent should be discovered by the controller and we can start delegating our jobs to the agents. We can restrict a job to run on a particular agent by using the labels we assigned when creating an agent.
