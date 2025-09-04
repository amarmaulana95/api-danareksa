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

    stage('Build Images') {
      steps {
        bat 'docker compose build'
      }
    }

    stage('Unit Testing') {
      steps {
        // start db dan app container
        bat 'docker compose up -d db'
        // tunggu db ready sebelum test
        bat 'docker compose exec -T app sh -c "until pg_isready -h db -U postgres; do sleep 1; done"'
        // jalanin test di container app
        bat 'docker compose exec -T app npm run test'
      }
      post {
        always {
          publishTestResults testResultsPattern: 'test-reports/junit.xml'
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

    stage('Build Image for Deploy') {
      steps {
        bat 'docker build -t api-danareksa:%BUILD_NUMBER% .'
        bat 'docker tag api-danareksa:%BUILD_NUMBER% api-danareksa:latest'
      }
    }

    stage('Deploy Dev') {
      when { branch 'main' }
      steps {
        bat 'docker compose up -d --build'
      }
    }

    stage('Health Check') {
      steps {
        bat 'timeout /t 5 /nobreak > nul'
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
