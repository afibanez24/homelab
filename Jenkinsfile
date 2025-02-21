pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-app"
        IMAGE_TAG = "latest"
        REGISTRY = "localhost:5000"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
        NAMESPACE = "homelab"  # 🚨 Antes era flask-app-space (incorrecto)
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
                sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                '''
            }
        }

        stage('Force Deployment Restart') {  # 🚀 Asegurar que Kubernetes use la nueva imagen
            steps {
                script {
                    sh "kubectl rollout restart deployment backend-deployment -n ${NAMESPACE} --kubeconfig=${KUBECONFIG}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh "kubectl get pods -n ${NAMESPACE} --kubeconfig=${KUBECONFIG}"
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