pipeline {
  agent any
  triggers { githubPush() }

  environment {
    PORT        = credentials('ENV_PORT')
    DB_HOST     = credentials('ENV_DB_HOST')
    DB_PORT     = credentials('ENV_DB_PORT')
    DB_NAME     = credentials('ENV_DB_NAME')
    DB_USER     = credentials('ENV_DB_USER')
    DB_PASSWORD = credentials('ENV_DB_PASSWORD')
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