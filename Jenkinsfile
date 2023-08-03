#!/bin/env groovy

def defaultBranch = 'master'
def githubCredentialsId = 'GH_TOKEN'

pipeline {
  agent any
  stages {
    stage('Test') {
      // when {
      //   allOf {
      //     not { branch defaultBranch }
      //     changeset 'MuleSoft/**'
      //   }
      // }
      steps {
        sh 'wget https://github.com/errata-ai/vale/releases/download/v2.28.0/vale_2.28.0_Linux_64-bit.tar.gz'
        sh 'mkdir bin && tar -xvzf vale_2.28.0_Linux_64-bit.tar.gz -C bin'
        sh 'export PATH=./bin:"$PATH"'
        sh 'vale'
      }
    }
    stage('Release') {
      when {
        allOf {
          branch defaultBranch
          changeset 'MuleSoft/**'
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
