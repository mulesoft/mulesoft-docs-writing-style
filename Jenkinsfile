#!/bin/env groovy

def defaultBranch = 'master'
def githubCredentialsId = 'GH_TOKEN'

pipeline {
  agent any
  stages {
    stage('Test') {
      when {
        allOf {
          not { branch defaultBranch }
          changeset "MuleSoft/**"
        }
      }
      steps {
        sh "docker build -f Dockerfile.test ."
      }
    }
    stage('Release') {
      when {
        allOf {
          branch defaultBranch
          changeset "MuleSoft/**"
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
