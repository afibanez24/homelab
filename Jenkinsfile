pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-app"
        IMAGE_TAG = "latest"
        REGISTRY = "localhost:5000"
        NAMESPACE = "flask-app-space"
        TERRAFORM_DIR = "terraform" // Ajusta si tu Terraform está en otro directorio
    }

    stages {

        stage('Clone Repository') {
            steps {
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs: [[
                            url: 'https://github.com/afibanez24/homelab.git',
                            credentialsId: 'github-credentials' // Asegúrate de usar el ID correcto
                        ]]
                    ])
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    if (sh(script: "which docker", returnStatus: true) == 0) {
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    } else {
                        error "Docker no está instalado o disponible en PATH."
                    }
                }
            }
        }

        stage('Push Image to Minikube') {
            steps {
                script {
                    if (sh(script: "which minikube", returnStatus: true) == 0) {
                        sh "minikube image load ${IMAGE_NAME}:${IMAGE_TAG}"
                    } else {
                        error "Minikube no está instalado o disponible en PATH."
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                script {
                    dir(TERRAFORM_DIR) {
                        if (sh(script: "which terraform", returnStatus: true) == 0) {
                            sh "terraform init"
                            sh "terraform apply -auto-approve"
                        } else {
                            error "Terraform no está instalado o disponible en PATH."
                        }
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    if (sh(script: "which kubectl", returnStatus: true) == 0) {
                        sh "kubectl get pods -n ${NAMESPACE}"
                    } else {
                        error "kubectl no está instalado o disponible en PATH."
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completado exitosamente."
        }
        failure {
            echo "❌ Hubo un fallo en el pipeline. Revisa los logs."
        }
        always {
            script {
                echo "📜 Logs de los últimos pods desplegados:"
                sh "kubectl get pods -n ${NAMESPACE} --sort-by=.metadata.creationTimestamp | tail -5"
            }
        }
    }
}