pipeline {
  agent any

  environment {
    SLACK_HOOK = credentials('slack_hook')
    DOCKER_HUB = credentials('docker_creds')
    PROJECT_NAME = 'scanthisspace'
    BRANCH_NAME = """${sh(
                      returnStdout: true,
                      script: 'git rev-parse --abbrev-ref HEAD'
    )}"""
    COMMIT_SHA = """${sh(
                      returnStdout: true,
                      script: 'git log -1 --format=%h'
    )}"""
  }
  stages {
    stage('Docker: build'){
      steps {
        script {
          sh  """
              docker build \
              . -t ${PROJECT_NAME}-${BRANCH_NAME}
              """
          sh 'docker images'
        }
      }
    }

    stage('Docker: tag and push image to registry'){
      steps {
        script {
          sh "docker login -u \"${DOCKER_HUB_USR}\" -p \"${DOCKER_HUB_PSW}\""
          sh "docker tag ${PROJECT_NAME}-${BRANCH_NAME} ${DOCKER_HUB_USR}/${PROJECT_NAME}-${BRANCH_NAME}:${COMMIT_SHA}"
          sh "docker tag ${PROJECT_NAME}-${BRANCH_NAME} ${DOCKER_HUB_USR}/${PROJECT_NAME}-${BRANCH_NAME}:latest"
          sh "docker push ${DOCKER_HUB_USR}/${PROJECT_NAME}-${BRANCH_NAME}:latest"
          sh "docker push ${DOCKER_HUB_USR}/${PROJECT_NAME}-${BRANCH_NAME}:${COMMIT_SHA}"
        }
      }
    }

    stage("Docker: cleanup") {
      steps {
        script {
          sh "docker system prune -a -f"
        }
      }
    }
  }
  post {
    failure {
      sh """#!/bin/bash 
      set -x
      cat slack_payload.json | jq -cr ".attachments[0].blocks[0].text.text = \"*JOB:* ${env.JOB_NAME}, *BUILD:* ${env.BUILD_NUMBER}\n\"" | jq -cr ".text = \"*<${env.BUILD_URL}|Jenkins DevOps Pipeline Failed!>*\"" | jq -c . > slack.json
      curl -X POST -H 'Content-type: application/json' --data '@slack.json' ${SLACK_HOOK}
      """
    }
  }
}
