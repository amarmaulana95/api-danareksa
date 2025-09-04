pipeline {
  agent any
  triggers { githubPush() }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/amarmaulana95/api-danareksa.git'
      }
    }

    stage('Build') {
      steps {
        script {
          if (isUnix()) {
            sh 'docker build -t api-danareksa .'
          } else {
            bat 'docker build -t api-danareksa .'
          }
        }
      }
    }

    stage('Up') {
      steps {
        script {
          if (isUnix()) {
            sh 'docker-compose up -d --build'
          } else {
            bat 'docker-compose up -d --build'
          }
        }
      }
    }
  }
}
