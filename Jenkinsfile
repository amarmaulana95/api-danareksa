pipeline {
  agent any
  triggers { githubPush() }

  stages {
    stage('Checkout') {
      steps { git 'https://github.com/amarmaulana95/api-danareksa.git' }
    }
    stage('Build') {
      steps { powershell 'docker build -t api-danareksa .' }
    }
    stage('Up') {
      steps { powershell 'docker-compose up -d --build' }
    }
  }
}