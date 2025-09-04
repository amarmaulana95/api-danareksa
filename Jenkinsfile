properties([
  pipelineTriggers([
    githubPush()
  ]),
  buildDiscarder(
    logRotator(daysToKeepStr: '7', numToKeepStr: '5')
  )
])

pipeline {
  agent any
  options {
    buildDiscarder logRotator(daysToKeepStr: '7', numToKeepStr: '5')
    timeout(time: 20, unit: 'MINUTES')
    timestamps()
  }
  triggers { githubPush() }

  stages {
    stage('Git Checkout') {
      steps { checkout scm }
    }

    stage('Build & Start Services') {
      steps {
        bat 'docker compose down --remove-orphans || exit 0'
        bat 'docker compose build --no-cache && docker compose up -d'
        bat 'docker compose up -d db'
        bat 'docker compose exec -T db pg_isready -U postgres'
        bat 'docker compose up -d app'
      }
    }

   stage('Unit Testing') {
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

    stage('Docker Tag Docker') {
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

    stage('Deploy') {
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

    stage('Service validation') {
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