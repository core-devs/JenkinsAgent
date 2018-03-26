#!/bin/bash

JENKINS_URL=$1
NODE_NAME=$2
NODE_SLAVE_HOME='/home/build/slave'
EXECUTORS=10
SSH_PORT=22
CRED_ID=$3
LABELS=build
USERID=${USER}

cat <<EOF | java -jar ./jenkins-cli.jar -s $1 -auth $3 create-node $2
<slave>
  <name>${NODE_NAME}</name>
  <description></description>
  <remoteFS>${NODE_SLAVE_HOME}</remoteFS>
  <numExecutors>${EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
  </launcher>
  <label></label>
  <nodeProperties/>
</slave>
EOF

SECRET=`echo "println jenkins.model.Jenkins.instance.nodesObject.getNode(\"$NODE_NAME\")?.computer?.jnlpMac" | java -jar ./jenkins-cli.jar -s $1 -auth $3 groovy =`
echo "[[${SECRET}]]"

java -jar agent.jar -jnlpUrl "$JENKINS_URL/computer/$NODE_NAME/slave-agent.jnlp" -secret ${SECRET} -workDir /home/jromero/pv/jenkins/slave00/