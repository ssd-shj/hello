pipeline {
    agent any

    parameters {
        string(name: 'NAME', defaultValue: 'World', description: 'Name to print at runtime')
    }

    environment {
        IMAGE_NAME = "shashankjf/hello-app"
        DOCKER_USER = credentials('dockerhub-creds')
        GIT_USER = credentials('github-creds')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh '''
                  docker build -t $IMAGE_NAME:${NAME}-${BUILD_NUMBER} .
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                sh '''
                  echo $DOCKER_USER_PSW | docker login -u $DOCKER_USER_USR --password-stdin
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                  docker push $IMAGE_NAME:${NAME}-${BUILD_NUMBER}
                '''
            }
        }

        stage('Run and Capture Output') {
            steps {
                sh '''
                  docker run --rm -e NAME=${NAME} $IMAGE_NAME:${NAME}-${BUILD_NUMBER} | tee runtime_output.txt
                '''
            }
        }

        stage('Commit Output to GitHub') {
            steps {
                sh '''
                  git config user.email "ci-bot@example.com"
                  git config user.name "Jenkins CI Bot"
                  git checkout $BRANCH_NAME
                  cp runtime_output.txt runtime_output_${NAME}_${BUILD_NUMBER}.txt
                  git add runtime_output_${NAME}_${BUILD_NUMBER}.txt
                  git commit -m "Add runtime output for NAME=${NAME}, build ${BUILD_NUMBER}"
                  git push https://${GIT_USER_USR}:${GIT_USER_PSW}@github.com/your-username/hello.git HEAD:$BRANCH_NAME
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}