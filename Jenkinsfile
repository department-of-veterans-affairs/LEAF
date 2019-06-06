def initial_clone(){
    withCredentials([usernamePassword(credentialsId: 'test-jenkins-api', passwordVariable: 'scm_pw', usernameVariable: 'scm_user')]) {
        sh '''
      git clone https://$scm_pw@github.ablevets.com/Delivery-Operations/jenkinsx_automation.git
    '''
    }
    def func_msg = "git clone successful"
    return func_msg;
}


pipeline {

    agent {
        label "jenkins-maven"
    }

    environment {
        external_clone = initial_clone()
        ORG = 'ccad'
        APP_NAME = 'leaf'
        CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
        ECR_REPO = 'ccad'
        SANITIZED_BRANCH_NAME = sh(returnStdout: true, script: "echo $BRANCH_NAME | sed 's/_/-/g' | sed 's@/@-@g' | sed 's/%2F/-/g' | sed 's/\\./-/g' | sed 's/sandbox/s/g' | sed 's/feature/f/g' | sed 's/improvement/i/g' | sed 's/uniformJenkinsfile/uj/g'").trim().toLowerCase()
        SHORT_COMMIT_HASH = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
        JOB_NAME = sh(returnStdout: true, script: "echo $JOB_NAME | sed 's/_/-/g' | sed 's@/@-@g' | sed 's/%2F/-/g' | sed 's/\\./-/g' | sed 's/sandbox/s/g' | sed 's/feature/f/g' | sed 's/improvement/i/g' | sed 's/uniformJenkinsfile/uj/g'").trim().take(47).toLowerCase()
    }

    stages {
        stage('CICD Initialize') {
            environment {
                INITIAL_PARSED_GIT_DATA_FILE_PATH = sh(returnStdout: true, script: "cat $WORKSPACE/jenkinsx_automation/pipeline_tools/cicd_initialize/cicd_initialize_env.groovy | grep INITIAL_PARSED_GIT_DATA_FILE | awk -F '=' '{ print \$2 }' | sed 's@\"@@g'").trim()
                gitParseExternalMethod = load("$INITIAL_PARSED_GIT_DATA_FILE_PATH")
                string_json_obj = gitParseExternalMethod.fetchGitData()
            }
            steps {
                script {
                    load("jenkinsx_automation/pipeline_tools/cicd_initialize/cicd_initialize_env.groovy")
                    sh """
                        ./$PATH_TO_CICD_INITIALIZE/$DRIVER_SCRIPT
                    """
                    load("${PATH_TO_TENABLE_CONTAINER_ENV_FILE}")
                    load("${PATH_TO_TENABLE_WEB_ENV_FILE}")
                    load("${PATH_TO_BUILD_METRICS_ENV_FILE}")
                    load("${PATH_TO_FORTIFY_ENV_FILE}")
                } //end script 
            } //end steps
        } //end stage

        stage('Image Build and Fortify') {
            parallel{
                stage("Fortify Scan"){
                    environment {
                        BRANCH_NAME = sh(returnStdout: true, script: "$WORKSPACE/$PATH_TO_BUILD_AUTO_CICD_INITIALIZE/$SANITIZE_BRANCH_NAME_SCRIPT").trim().toLowerCase()
                        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
                        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase().take(49)
                        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
                    }
                    steps {
                        container('fortify-18-20-con'){
                            sh """
                                $PATH_TO_FORTIFY/$FORTIFY_DRIVER
                            """
                        }
                    }
                }
                stage("App Build and Image Build"){
                    environment {
                        BRANCH_NAME = sh(returnStdout: true, script: "$WORKSPACE/$PATH_TO_BUILD_AUTO_CICD_INITIALIZE/$SANITIZE_BRANCH_NAME_SCRIPT").trim().toLowerCase()
                        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
                        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase().take(49)
                        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
                    }
                    steps {
                        container('maven') {
                            sh "./build.sh"
                            sh "export VERSION=$PREVIEW_VERSION && export APP_NAME=$APP_NAME-mysql && skaffold build -f docker/mysql/skaffold.yaml"
                            sh "jx step post build --image $DOCKER_REGISTRY/$ECR_REPO/$APP_NAME-mysql:$PREVIEW_VERSION"
                            sh "export VERSION=$PREVIEW_VERSION && export APP_NAME=$APP_NAME-php && skaffold build -f docker/php/skaffold.yaml"
                            sh "jx step post build --image $DOCKER_REGISTRY/$ECR_REPO/$APP_NAME-php:$PREVIEW_VERSION"

                        }
                    }
                }
            }
        }
    } //end stages
    post {
        always {
            echo "POST ALWAYS STAGE"
        }
        // Jenkins API is inconsistent with build results, aborted builds are treated as failed. We can NOT rely on currentBuild.Result or currentBuild.currentResult
        success {
            script {
                echo "POST SUCCESS STAGE"
                sh """
                    echo "SUCCESS" > $FINAL_BUILD_RESULT_FILE
                """
            } // end script
        } // end success
        failure {
            script {
                echo "POST FAILURE STAGE"
                sh """
                    echo "FAILURE" > $FINAL_BUILD_RESULT_FILE
                """
            } //end script
        } //end failure
        aborted {
            script {
                echo "POST ABORTED STAGE"
                sh """
                    echo "ABORTED" > $FINAL_BUILD_RESULT_FILE
                """
            } //end script
        } //end aborted
        cleanup {
            container('python') {
                withCredentials([usernamePassword(credentialsId: 'test-jenkins-api', passwordVariable: 'readonly_pw', usernameVariable: 'readonly_user'), usernamePassword(credentialsId: 'smtp-user', passwordVariable: 'smtp_pw', usernameVariable: 'smtp_username')]) {
                    script {
                        load("${PATH_TO_BUILD_METRICS_ENV_FILE}")
                        sh """
                            $PATH_TO_BUILD_METRICS/$DRIVER_SCRIPT
                        """
                    } //end script
                } //end withCredentials
            } //end container
            script {
                load("${PATH_TO_BUILD_METRICS_ENV_FILE}")
                if (fileExists("$PATH_TO_BUILD_METRICS/$BUILD_METRICS_REPORT_LOG_FILE")) {
                    //dir (WORKSPACE){
                    emailext(
                            attachLog: true,
                            body: "BUILD URL: ${BUILD_URL}",
                            attachmentsPattern: "${BUILD_METRICS_REPORT_LOG_FILE_ATTACHMENT_STRING}",
                            compressLog: true,
                            subject: "Build Metrics Failure: ${JOB_NAME}-Build# ${BUILD_NUMBER}",
                            to: "${EMAIL_LIST}"
                    )
                    //}
                } //end if
            }//end script
            archiveArtifacts artifacts: '**/out/**', allowEmptyArchive: true, fingerprint: true
            cleanWs()
        } //end cleanup
    } //end post
} //end pipeline