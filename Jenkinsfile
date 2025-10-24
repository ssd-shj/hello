pipeline {
    agent any

    parameters {
        string(name: 'NAME', defaultValue: 'World', description: 'Name to print at runtime')
    }

    environment {
        IMAGE_NAME = "shashankjf/hello-app"
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                 usernameVariable: 'DOCKER_USER',
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
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

        stage('Publish Artifact') {
            steps {
                archiveArtifacts artifacts: 'runtime_output.txt', fingerprint: true
            }
        }

        stage('Commit Output to GitHub') {
            steps {
                withCredentials([string(credentialsId: 'github-api-token', variable: 'GIT_TOKEN')]) {
                    sh '''
                      git config user.email "ci-bot@example.com"
                      git config user.name "Jenkins CI Bot"
                      git checkout $BRANCH_NAME
                      cp runtime_output.txt runtime_output_${NAME}_${BUILD_NUMBER}.txt
                      git add runtime_output_${NAME}_${BUILD_NUMBER}.txt
                      git commit -m "Add runtime output for NAME=${NAME}, build ${BUILD_NUMBER}"
                      git push https://$GIT_TOKEN@github.com/ssd-/hello.git $BRANCH_NAME
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}