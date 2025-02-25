pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-app"
        IMAGE_TAG = "latest"
        REGISTRY = "localhost:5000"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
        NAMESPACE = "homelab"
        ELASTIC_URL = "http://localhost:9200/jenkins-logs/_doc/"
        JENKINS_LOG="/var/log/jenkins/jenkins.log"  // RUTA DEL LOG
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    sh 'echo "Iniciando clonación del repositorio..."'
                    checkout scm
                    sendLogsToElasticsearch("Clone Repository", "success")
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                        sendLogsToElasticsearch("Build Docker Image", "success")
                    } catch (Exception e) {
                        sendLogsToElasticsearch("Build Docker Image", "failure")
                        throw e
                    }
                }
            }
        }

        stage('Push Image to Minikube') {
            steps {
                script {
                    try {
                        sh "minikube image load ${IMAGE_NAME}:${IMAGE_TAG}"
                        sendLogsToElasticsearch("Push Image to Minikube", "success")
                    } catch (Exception e) {
                        sendLogsToElasticsearch("Push Image to Minikube", "failure")
                        throw e
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                script {
                    try {
                        sh '''
                            cd terraform
                            terraform init
                            terraform apply -auto-approve
                        '''
                        sendLogsToElasticsearch("Deploy with Terraform", "success")
                    } catch (Exception e) {
                        sendLogsToElasticsearch("Deploy with Terraform", "failure")
                        throw e
                    }
                }
            }
        }

        stage('Force Deployment Restart') {
            steps {
                script {
                    try {
                        sh "kubectl rollout restart deployment backend-deployment -n ${NAMESPACE} --kubeconfig=${KUBECONFIG}"
                        sendLogsToElasticsearch("Force Deployment Restart", "success")
                    } catch (Exception e) {
                        sendLogsToElasticsearch("Force Deployment Restart", "failure")
                        throw e
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    try {
                        sh "kubectl get pods -n ${NAMESPACE} --kubeconfig=${KUBECONFIG}"
                        sendLogsToElasticsearch("Verify Deployment", "success")
                    } catch (Exception e) {
                        sendLogsToElasticsearch("Verify Deployment", "failure")
                        throw e
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                echo "✅ Pipeline ejecutado con éxito"
                sendLogsToElasticsearch("Pipeline", "success")
            }
        }
        failure {
            script {
                echo "❌ Hubo un fallo en el pipeline. Revisa los logs."
                sendLogsToElasticsearch("Pipeline", "failure")
            }
        }
    }
}

// 🔹 Función Mejorada para Enviar Logs a Elasticsearch
def sendLogsToElasticsearch(stageName, status) {
    script {
        def buildLog = ""

        // ⚠️ Validamos si el archivo de log existe antes de leerlo
        try {
            buildLog = sh(script: "[ -f ${JENKINS_LOG} ] && tail -n 50 ${JENKINS_LOG} || echo 'No logs available'", returnStdout: true).trim()
        } catch (Exception e) {
            buildLog = "No logs available"
        }

        // 🚀 Enviamos el log a Elasticsearch
        sh """
        curl -X POST -H "Content-Type: application/json" -d '
        {
            "timestamp": "${new Date().format("yyyy-MM-dd'T'HH:mm:ss")}",
            "job": "${env.JOB_NAME}",
            "branch": "${env.BRANCH_NAME}",
            "build": "${env.BUILD_NUMBER}",
            "stage": "${stageName}",
            "status": "${status}",
            "log": "${buildLog}"
        }' ${ELASTIC_URL} || echo "⚠️ No se pudo enviar log a Elasticsearch"
        """
    }
}