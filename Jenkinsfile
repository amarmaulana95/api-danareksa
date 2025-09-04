pipeline {
  agent {
    docker {
        image 'docker:dind'   // atau langsung bind host Docker
        args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  
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
            powershell 'docker build -t api-danareksa .'
        }
    }
    
    stage('Up') {
        steps {
            powershell 'docker-compose up -d --build'
        }
    }
  }
}
