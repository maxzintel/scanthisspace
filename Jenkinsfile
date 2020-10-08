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
      sh "chmod +x ./send_slack.sh"
      sh "./send_slack.sh ${env.JOB_NAME} ${env.BUILD_NUMBER} ${env.BUILD_URL} ${SLACK_HOOK}"
    }
  }
}
