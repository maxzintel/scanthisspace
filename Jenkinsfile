def pipelineSteps = new PipelineSteps(this)
def projectName = pipelineSteps.multiBranchDisplayName()

def registry = "" 
def tagName = "scanthisspace"

pipeline {
  agent { label projectName }

  environment {
    CICD_CREDENTIALS = credentials('jenkins-creds')
    SLACK_HOOK = 'https://example.com'
  }
  stages {
    stage('Docker: build'){
      steps {
        script {
          sh  """
              docker build \
              . -t ${tagName}
              """
          sh 'docker images'
        }
      }
    }

    stage('Docker: tag and push image to registry'){
      steps {
        script {
          sh "docker login ${registry} -u \"${CICD_CREDENTIALS_USR}\" -p \"${CICD_CREDENTIALS_PSW}\""
          sh "docker tag ${tagName} ${registry}/${tagName}:\$(docker inspect --format='{{.ContainerConfig.Labels.version}}' ${tagName})"
          sh "docker push ${registry}/${tagName}:\$(docker inspect --format='{{.ContainerConfig.Labels.version}}' ${tagName})"
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
      sh """
      cat slack_payload.json | jq -cr ".attachments[0].blocks[0].text.text = \"*JOB:* ${env.JOB_NAME}, *BUILD:* ${env.BUILD_NUMBER}\n\"" | jq -cr ".text = \"*<${env.BUILD_URL}|Docker Jenkins DevOps Pipeline Failed!>*\"" | jq -c . > slack.json
      curl -X POST -H 'Content-type: application/json' --data '@slack.json' ${SLACK_HOOK}
      """
    }
  }
}
