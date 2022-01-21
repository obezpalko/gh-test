pipeline {
    agent { label 'agent1'}
    environment {
        DOCKERHUB_CREDENTIALS=credentials('dockerhub')
    }
    stages {
        stage('Build') {
            steps {
                git branch: 'main', url: 'https://github.com/obezpalko/gh-test.git/'
                sh 'docker build -t obezpalko/gh-test:snapshot .'
            }
        }
        stage('Login to dockerhub'){
            steps {
                sh 'echo "${DOCKERHUB_CREDENTIALS#*:}" | docker login --username="${DOCKERHUB_CREDENTIALS%:*}" --password-stdin'
            }
        }
        stage('Push to dockerhub'){
            steps {
                sh 'docker push obezpalko/gh-test:snapshot'
            }
        }
    }
}
