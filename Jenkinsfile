pipeline {
  agent any
  triggers { githubPush() }

  environment {
    PORT        = credentials('PORT')
    DB_HOST     = credentials('DB_HOST')
    DB_PORT     = credentials('DB_PORT')
    DB_NAME     = credentials('DB_NAME')
    DB_USER     = credentials('DB_USER')
    DB_PASSWORD = credentials('DB_PASSWORD')
  }

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