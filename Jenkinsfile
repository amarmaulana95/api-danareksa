properties([
  pipelineTriggers([githubPush()]),
  buildDiscarder(logRotator(daysToKeepStr: '7', numToKeepStr: '5'))
])

pipeline {
  agent any
  options {
    buildDiscarder logRotator(daysToKeepStr: '7', numToKeepStr: '5')
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
  }

  stages {
    stage('Checkout Code') {
      steps { checkout scm }
    }

    // ---------- EARLY FAIL-FAST ----------
    stage('Semgrep SAST') {
      steps {
        echo 'Semgrep SAST (dummy) – scanning...'
        bat 'timeout /t 5 >nul'
        bat 'echo SAST pass > semgrep-dummy.txt'
      }
    }

    stage('TruffleHog Secret Scan') {
      steps {
        echo 'TruffleHog Secret Scan (dummy) – scanning...'
        bat 'timeout /t 4 >nul'
        bat 'echo Secret pass > trufflehog-dummy.txt'
      }
    }
    // -------------------------------------

    stage('Dependency Scan') {
      steps {
        echo 'OWASP Dependency-Check (dummy) – analyzing...'
        bat 'timeout /t 6 >nul'
        bat 'echo Dep pass > dep-dummy.txt'
      }
    }

    stage('Build Test Image') {
      steps {
        bat 'docker build -t api-danareksa:latest .'
      }
    }

    stage('Trivy Image Scan') {
      steps {
        echo 'Trivy Image Scan (dummy) – scanning image...'
        bat 'timeout /t 7 >nul'
        bat 'echo Image pass > trivy-dummy.txt'
      }
    }

    stage('Start Services') {
      steps {
        bat 'docker compose down --remove-orphans || exit 0'
        bat 'docker compose up -d'
        bat 'docker compose exec -T db pg_isready -U postgres'
      }
    }

    stage('Unit Test') {
      steps {
        bat 'if exist coverage rmdir /s /q coverage'
        bat 'docker compose exec -T app npm test -- --ci --forceExit --reporters=default --reporters=jest-junit'
      }
      post {
        always {
          junit 'test-reports/junit.xml'
        }
      }
    }

    stage('SonarQube Scan') {
      steps {
        echo 'SonarQube Scan (dummy) – analyzing code quality...'
        bat 'timeout /t 8 >nul'
        bat 'echo Sonar pass > sonar-dummy.txt'
      }
    }

    stage('Tag & Push Image') {
      steps {
        script {
          def IMAGE = "api-danareksa"
          def VERSION = "${BUILD_NUMBER}"
          bat "docker tag ${IMAGE}:latest ${IMAGE}:${VERSION}"
          bat "docker tag ${IMAGE}:latest ${IMAGE}:prod-${VERSION}"
          echo "Tagged: ${IMAGE}:${VERSION} & prod-${VERSION}"
        }
      }
    }

    stage('Nexus Publish') {
      steps {
        echo 'Nexus Publish (dummy) – pushing artifact...'
        bat 'timeout /t 5 >nul'
        bat 'echo Nexus publish done > nexus-dummy.txt'
      }
    }

    stage('Deploy to Staging') {
      when {
        anyOf {
          expression { env.BRANCH_NAME == 'main' }
          expression { env.GIT_BRANCH == 'origin/main' }
        }
      }
      steps {
        bat 'docker compose up -d --build'
      }
    }

    stage('ZAP DAST') {
      steps {
        echo 'ZAP DAST (dummy) – attacking endpoints...'
        bat 'timeout /t 9 >nul'
        bat 'echo DAST pass > zap-dummy.txt'
      }
    }

    stage('Smoke Test') {
      steps {
        bat 'docker compose exec -T app curl -f http://localhost:3000 || exit 1'
      }
    }
  }

  post {
    always  { bat 'echo Pipeline selesai.' }
    success { bat 'echo Build sukses - semua stage hijau.' }
    failure { bat 'echo Build gagal - ada stage merah.' }
    cleanup { bat 'docker image prune -f' }
  }
}
