#!/bin/env groovy

def defaultBranch = 'master'
def githubCredentialsId = 'GH_TOKEN'

pipeline {
  agent any
  stages {
    stage('Release') {
      when {
        branch defaultBranch
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
