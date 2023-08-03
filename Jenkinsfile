#!/bin/env groovy

def defaultBranch = 'master'
def everythingInsideMulesoftDir = 'MuleSoft/**'
def githubCredentialsId = 'GH_TOKEN'

def nodeVersion = '18'

// update this to the latest version showing in https://github.com/errata-ai/vale/releases
def valeVersion = '2.28.1'

pipeline {
  agent any
  stages {
    stage('Set Up') {
      steps {
        installNode(nodeVersion)
        installNodeDependencies()
        installVale(valeVersion)
      }
    }
    stage('Test') {
      when {
        allOf {
          not { branch defaultBranch }
          changeset everythingInsideMulesoftDir
        }
      }
      steps {
        sh './vale .'
      }
    }
    stage('Release') {
      when {
        allOf {
          branch defaultBranch
          changeset everythingInsideMulesoftDir
        }
      }
      steps {
        withCredentials([
          string(credentialsId: githubCredentialsId, variable: 'GH_TOKEN')]) {
            sh "docker build --build-arg GH_TOKEN=${GH_TOKEN} --build-arg GIT_BRANCH=${env.GIT_BRANCH} -f Dockerfile ."
          }
      }
    }
  }
}

void installNode(String nodeVersion) {
  withCredentials([string(credentialsId: 'NPM_TOKEN', variable: 'NPM_TOKEN')]) {
    sh "curl -fsSL https://deb.nodesource.com/setup_${nodeVersion}.x | sudo -E bash - && sudo apt-get install -y nodejs"
    sh 'npm config set @mulesoft:registry=https://nexus3.build.msap.io/repository/npm-internal/{'
    sh "npm config set //nexus3.build.msap.io/repository/npm-internal/:_authToken=${NPM_TOKEN}"
  }
}

void installNodeDependencies() {
  sh 'npm ci --cache=.cache/npm --no-audit'
}

void installVale(String valeVersion) {
  sh "wget https://github.com/errata-ai/vale/releases/download/v${valeVersion}/vale_${valeVersion}_Linux_64-bit.tar.gz"
  sh "tar -xvzf vale_${valeVersion}_Linux_64-bit.tar.gz -C ./"
}
