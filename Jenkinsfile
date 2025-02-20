pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-app"
        IMAGE_TAG = "latest"
        REGISTRY = "localhost:5000"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push Image to Minikube') {
            steps {
                script {
                    sh "minikube image load ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                script {
                    sh "terraform init"
                    sh "terraform apply -auto-approve"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh "kubectl get pods -n flask-app-space --kubeconfig=${KUBECONFIG}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline ejecutado con éxito"
        }
        failure {
            echo "❌ Hubo un fallo en el pipeline. Revisa los logs."
        }
    }
}