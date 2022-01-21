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
                // git branch: 'main', url: 'https://github.com/obezpalko/gh-test.git/'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t obezpalko/gh-test:latest .'
            }
        }
        stage('Login to dockerhub'){
            steps {
                sh 'echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login --username="${DOCKERHUB_CREDENTIALS_USR}" --password-stdin'
            }
        }
        stage('Push to dockerhub'){
            steps {
                sh 'docker push obezpalko/gh-test:latest'
            }
        }
    }
    post {
        always {
                sh 'docker logout'
        }
    }
}
