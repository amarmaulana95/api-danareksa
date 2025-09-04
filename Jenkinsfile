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
        checkout scm
      }
    }

    stage('Install Dependencies') {
      steps {
        bat 'npm ci'
      }
    }

   stage('Unit Testing') {
        steps {
            bat 'docker compose exec -T app npm test -- --ci --reporters=default --reporters=jest-junit'
        }
        post {
            always {
            junit 'test-reports/junit.xml'
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportName: 'Coverage Report'
            ])
            }
        }
    }


    stage('Build Image') {
      steps {
        bat 'docker build -t api-danareksa:%BUILD_NUMBER% .'
        bat 'docker tag api-danareksa:%BUILD_NUMBER% api-danareksa:latest'
      }
    }

   stage('Deploy') {
    when { 
        anyOf {
        expression { env.BRANCH_NAME == 'main' }
        expression { env.GIT_BRANCH == 'origin/main' }
        }
    }
    steps {
        bat 'docker-compose up -d --build'
    }
    }


   stage('Health Check') {
    steps {
        // Delay 5 detik (silent)
        bat 'ping -n 6 127.0.0.1 >nul'
        
        // Cek service
        bat 'curl -f http://localhost:3000 || exit 1'
    }
    }

  }

  post {
    always {
      bat 'echo Pipeline selesai.'
    }
    success {
      bat 'echo Build sukses - semua stage hijau.'
    }
    failure {
      bat 'echo Build gagal - ada stage merah.'
    }
    cleanup {
      bat 'docker image prune -f'
    }
  }
}