#!/bin/env groovy

def defaultBranch = 'master'
def githubCredentialsId = 'GH_TOKEN'
def valeVersion = '2.28.1'

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
        sh "wget https://github.com/errata-ai/vale/releases/download/v${valeVersion}/vale_${valeVersion}_Linux_64-bit.tar.gz"
        sh "tar -xvzf vale_${valeVersion}_Linux_64-bit.tar.gz -C ./"
        sh './vale'
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
