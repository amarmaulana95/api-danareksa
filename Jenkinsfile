pipeline {
  agent any
  triggers { githubPush() }
  stages {
    stage('Checkout') {
      steps { git 'https://github.com/amarmaulana95/api-danareksa.git' }
    }
    stage('Build') {
      steps { sh 'docker build -t api-danareksa .' }
    }
    stage('Up') {
      steps { sh 'docker-compose up -d --build' }
    }
  }
}