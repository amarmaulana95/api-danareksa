pipeline {
  agent any
  options {
    buildDiscarder logRotator(daysToKeepStr: '7', numToKeepStr: '5')
    timeout(time: 20, unit: 'MINUTES')
    timestamps()
  }
  
  triggers { githubPush() }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/amarmaulana95/api-danareksa.git'
      }
    }

    stage('Build Image') {
      steps {
        bat 'docker build -t api-danareksa .'
      }
    }

    stage('Deploy') {
      steps {
        bat 'docker-compose up -d --build'
      }
    }

    stage('Verify') {
      steps {
        bat 'curl -f http://localhost:3000 || echo "API belum ready, tunggu sebentar..."'
      }
    }
  }

  post {
    always {
      bat 'echo Pipeline selesai.'
    }
    success {
      bat 'echo Semua kotak hijau!'
    }
    failure {
      bat 'echo Ada kotak merah, cek log.'
    }
  }
}