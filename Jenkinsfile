pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-app"
        IMAGE_TAG = "latest"
        REGISTRY = "localhost:5000"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/afibanez24/homelab.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push Image to Minikube') {
            steps {
                sh "minikube image load ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy with Terraform') {
            steps {
                sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods -n flask-app-space"
            }
        }
    }
}