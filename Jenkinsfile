properties([
  parameters([
    string(name: 'TAG_NAME', defaultValue: '', description: 'Git tag to deploy (v*)')
  ]),
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
    stage('GIT Checkout') {
      steps { checkout scm }
    }

    /* ---------- FAIL-FAST SECURITY ---------- */
    stage('SAST (Semgrep)') {
      steps {
        bat 'docker run --rm -v "%WORKSPACE%":/src -w /src returntocorp/semgrep:1.45.0 semgrep --config=auto --error src/'
      }
    }

    stage('Secret Scan (TruffleHog)') {
      steps {
        bat 'trufflehog.exe git file://. --only-verified --json > trufflehog.json'
      }
      post {
        always {
          archiveArtifacts artifacts: 'trufflehog.json', allowEmptyArchive: true
          recordIssues tool: truffleHog(pattern: 'trufflehog.json')
        }
      }
    }

    stage('Dependency Check (OWASP)') {
      steps {
        echo 'OWASP Dep-Check (dummy) – analyzing...'
        bat 'ping -n 7 127.0.0.1 >nul'
        bat 'echo Dep pass > dep-dummy.txt'
      }
    }

    /* ---------- BUILD & UNIT TEST ---------- */
   stage('Build Test Image') {
      steps {
        bat '''
          set DOCKER_BUILDKIT=1
          docker build ^
            --build-arg BUILDKIT_INLINE_CACHE=1 ^
            --cache-from api-danareksa:cache ^
            -t api-danareksa:cache ^
            -t api-danareksa:latest .
        '''
      }
    }

    stage('Unit Test + Coverage') {
      steps {
        bat '''
          if not exist coverage   mkdir coverage
          if not exist test-reports mkdir test-reports
          docker compose exec -T app npm test -- --coverage --ci --forceExit \
            --reporters=default --reporters=jest-junit
          docker compose cp app:/app/coverage/lcov.info coverage/lcov.info
          docker compose cp app:/app/test-reports/junit.xml test-reports/junit.xml
        '''
      }
      post { always { junit 'test-reports/junit.xml' } }
    }

    /* ---------- QUALITY GATE ---------- */
    stage('SonarCloud Scan') {
      steps {
        withSonarQubeEnv('sonarcloud') {
          bat """
            "${tool 'SonarScanner'}\\bin\\sonar-scanner.bat" ^
            -Dsonar.projectKey=amarmaulana95_api-danareksa ^
            -Dsonar.organization=amarmaulana95 ^
            -Dsonar.host.url=https://sonarcloud.io ^
            -Dsonar.sources=src ^
            -Dsonar.tests=. ^
            -Dsonar.test.inclusions=**/*.test.js,**/*.spec.js ^
            -Dsonar.exclusions=node_modules/**,coverage/**,*.txt,*.log ^
            -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
          """
        }
      }
    }

    /* ---------- IMAGE HARDENING ---------- */
    stage('Trivy Image Scan') {
      steps {
        // 1. pastikan binary ada (cukup di-download sekali seumur hidup agent)
        bat '''
          if not exist trivy.exe (
            curl -L -o trivy.zip https://github.com/aquasecurity/trivy/releases/download/v0.50.1/trivy_0.50.1_windows-64bit.zip
            tar -xf trivy.zip trivy.exe & del trivy.zip
          )
        '''

        // 2. scan langsung image lokal; exit 1 kalau HIGH/CRITICAL
        bat 'trivy.exe image --severity HIGH,CRITICAL --ignore-unfixed api-danareksa:latest'
      }
    }

    /* ---------- STAGING & VALIDATION ---------- */
    stage('Deploy to Staging') {
      when {
        anyOf {
          expression { env.BRANCH_NAME == 'main' }
          expression { env.GIT_BRANCH == 'origin/main' }
        }
      }
      steps {
        bat 'docker compose up -d --build'
        bat 'docker compose exec -T db pg_isready -U postgres'
      }
    }

    stage('Smoke Test') {
      steps {
        bat 'docker compose exec -T app curl -f http://localhost:3000 || exit 1'
      }
    }

    stage('DAST (ZAP)') {
      steps {
        echo 'ZAP DAST (dummy) – attacking endpoints...'
        bat 'ping -n 10 127.0.0.1 >nul'
        bat 'echo DAST pass > zap-dummy.txt'
      }
    }

    /* ---------- PUBLISH & TAG ---------- */
    stage('Tag & Push Image') {
      steps {
        script {
          def IMAGE = 'api-danareksa'
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
        bat 'ping -n 6 127.0.0.1 >nul'
        bat 'echo Nexus publish done > nexus-dummy.txt'
      }
    }

    /* ---------- PRODUCTION (manual gate) ---------- */
    stage('Deploy to Production') {
      when {
        expression { params.TAG_NAME?.startsWith('v') }
      }
      steps {
        input message: "Deploy ${params.TAG_NAME} ke PROD ?", ok: 'Deploy'
        script {
          bat """
            docker build -t api-danareksa:${params.TAG_NAME} .
            set BUILD_NUMBER=${params.TAG_NAME}
            set DB_USER=postgres
            set DB_PASS=postgres
            docker rm -f api-prod || exit 0
            docker compose -f docker-compose.prod.yml up -d --no-deps api-prod
          """
        }
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