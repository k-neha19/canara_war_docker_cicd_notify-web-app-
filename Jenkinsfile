pipeline {
    agent any
    
    environment {
        DOCKERHUB_USERNAME = 'sakit333'
        DOCKER_IMAGE = "${DOCKERHUB_USERNAME}/canara_sak"
        DOCKER_CONTAINER = 'canara_app_sak'
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Select deployment environment')
        choice(name: 'ACTION', choices: ['deploy', 'remove'], description: 'Select action to perform')
        string(name: 'RECEIVER_EMAIL', defaultValue: 'sak@gmail.com', description: 'Comma-separated recipient emails')
    }

    stages {
        stage('Run in the Dev Environment') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'dev' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                echo 'Deploying to Development Environment'
                sh '''
                    sudo docker-compose down
                    sudo docker-compose up -d --build
                '''
            }
            post {
                success {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "DEV ENV DEPLOY SUCCESS" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
                failure {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "DEV ENV DEPLOY FAILURE" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
            }
        }
        stage("Remove container in Dev Environment") {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'dev' }
                    expression { params.ACTION == 'remove' }
                }
            }
            steps {
                echo 'Stopping Development Environment'
                sh 'sudo docker-compose down'
                sh 'sudo docker system prune -af'
            }
            post {
                success {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "DEV ENV REMOVE SUCCESS" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
                failure {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "DEV ENV REMOVE FAILURE" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
            }
        }
        stage('Build Docker Image') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                sh 'sudo docker build -t $DOCKER_IMAGE .'
            }
        }
        stage('Login to Docker Hub') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-cred', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh 'echo $DOCKERHUB_PASS | sudo docker login -u $DOCKERHUB_USER --password-stdin'
                }
            }
        }
        stage('Docker tag with Build ID') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                sh "sudo docker tag $DOCKER_IMAGE $DOCKER_IMAGE:${env.BUILD_ID}"
            }
        }
        stage('Push to Dockerhub both latest and build id') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                sh 'sudo docker push $DOCKER_IMAGE:${BUILD_ID}'
                sh 'sudo docker push $DOCKER_IMAGE:latest'
            }
        }
        stage('Logout from Docker Hub') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                sh 'sudo docker logout'
            }
        }
        stage('Clean up Local Docker Images') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                sh '''
                    sudo docker rmi $DOCKER_IMAGE:${BUILD_ID} $DOCKER_IMAGE:latest
                    sudo docker image prune -af
                '''
            }
        }
        stage('Deploy Docker Container in Production Server') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                sh '''
                    echo "🚀 Pulling latest image..."
                    sudo docker pull $DOCKER_IMAGE:latest

                    echo "🧹 Removing existing container if running..."
                    if [ "$(sudo docker ps -aq -f name=$DOCKER_CONTAINER)" ]; then
                        sudo docker rm -f $DOCKER_CONTAINER
                    fi

                    echo "✅ Starting new container..."
                    sudo docker run -d --restart always --name $DOCKER_CONTAINER -p 8085:8080 $DOCKER_IMAGE:latest
                '''
            }
            post {
                success {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "PROD ENV DEPLOY SUCCESS" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
                failure {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "PROD ENV DEPLOY FAILURE" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
            }
        }
        stage('Remove Docker Container in Production Server') {
            when {
                allOf {
                    expression { params.ENVIRONMENT == 'prod' }
                    expression { params.ACTION == 'remove' }
                }
            }
            steps {
                sh '''
                    echo "Cleaning Docker Container & Image..."
                    if [ "$(sudo docker ps -aq -f name=$DOCKER_CONTAINER)" ]; then
                        echo "Removing existing container $DOCKER_CONTAINER"
                        sudo docker rm -f $DOCKER_CONTAINER
                    else
                        echo "No container found with name $DOCKER_CONTAINER"
                    fi
                    if sudo docker images | grep -q "$DOCKER_IMAGE"; then
                        echo "Removing docker image $DOCKER_IMAGE"
                        sudo docker rmi -f $DOCKER_IMAGE:latest
                    else
                        echo "No image found with name $DOCKER_IMAGE"
                    fi
                    echo "Cleanup Completed!"
                '''
            }
            post {
                success {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "PROD ENV REMOVE SUCCESS" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
                failure {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'GMAIL_GMAILAUTH', usernameVariable: 'GMAIL_USER', passwordVariable: 'GMAIL_APP_PASS')]) {
                            sh """
                            chmod +x jenkins_notify.sh || true

                            GMAIL_USER=\$GMAIL_USER \
                            GMAIL_APP_PASS=\$GMAIL_APP_PASS \
                            ./jenkins_notify.sh "PROD ENV REMOVE FAILURE" "$JOB_NAME" "$BUILD_ID" "$RECEIVER_EMAIL"
                            """
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}