pipeline {
  agent {
    label "jenkins-jx-base"
  }
  environment {
    ORG = 'avdockerid'
    APP_NAME = 'leaf' 
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    TILLER_NAMESPACE = "kube-system"
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('jx-base') {
          sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          dir('./charts/preview') {
            sh "make preview"
            sh "jx preview --no-comment=true --app $APP_NAME --dir ../.."
          }
        }
      }
    }
    stage('CI Tests') {
      agent {
        label "jenkins-gradle"
      }
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('gradle') {
          dir('./api-tests') {

            sh """
              sleep 10
              export DB_HOST="leafdb-mysql.jx-ablevets-bot-\${PREVIEW_NAMESPACE}"
              export WEB_HOST="leaf.jx-ablevets-bot-\${PREVIEW_NAMESPACE}"

              echo db_host=\${DB_HOST} > gradle.properties
              echo web_host=\${WEB_HOST} >> gradle.properties

              ./gradlew --no-daemon --max-workers 2 clean compileTestGroovy
              ./gradlew --no-daemon --max-workers 2 test
            """

          }
        }
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: 'api-tests/build/test-results/test/*.xml'
        }
      }
    }
    stage('Build Release') {
      when {
        branch 'dev'
      }
      steps {
        container('jx-base') {

          // ensure we're not on a detached head
          sh "git checkout dev"
          sh "git config --global credential.helper store"
          sh "jx step git credentials"
          sh "jx step next-version --use-git-tag-only --tag"
          sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
        }
      }
    }
    stage('Promote to Environments') {
      when {
        branch 'dev'
      }
      steps {
        container('jx-base') {
          dir('./charts/leaf') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
    stage('Run fortify') {
      when {
        branch 'dev'
      }
      steps {
        container('fortify-code-security') {
          sh '/mnt/workspace/fortify.sh'
        }
        archiveArtifacts artifacts: 'fortify/**', allowEmptyArchive: true, fingerprint: true
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}
