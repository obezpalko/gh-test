pipeline {
    agent { label 'agent1'}
    environment {
        DOCKERHUB_CREDENTIALS=credentials('dockerhub')
    }
    stages {
        stage('Clone') {
            steps {
                script {
                    def s = checkout scm;
                }
            }
        }
        stage('Build') {
            steps {
                sh "docker build -t obezpalko/gh-test:latest -t obezpalko/gh-test:\$(sed -r '/appVersion:/!d; s/appVersion:\\s*/v/' gh-test-chart/Chart.yaml) ."
            }
        }
        stage('Login to dockerhub'){
            steps {
                sh 'echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login --username="${DOCKERHUB_CREDENTIALS_USR}" --password-stdin'
            }
        }
        stage('Push to dockerhub'){
            steps {
                sh "docker push --all-tags obezpalko/gh-test"
            }
        }
    }
    post {
        always {
                sh 'docker logout'
        }
    }
}
