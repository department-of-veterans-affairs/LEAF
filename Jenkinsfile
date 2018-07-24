node {
    echo "Current dir: ${env.PWD}"
    echo "Current Workspace: ${env.WORKSPACE}"
    sh 'ls -l'

    echo "Clean Workspace: Before execution"
    cleanWs()

    echo "Checkout SCM"
	checkout scm
    echo "ls -l"
	sh 'ls -l'

    echo "Checkout build_automation project from source"
	checkout([$class: 'GitSCM', branches: [[name: 'leaf']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'build_automation']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c07e71bc-f3f0-4d5a-9d43-a97236b89f1d', url: 'https://demo.ablevets.com/coderepo/scm/avss/build_automation.git']]])
    echo "ls -l"
	sh 'ls -l'

    echo "Load Jenkinsfile in build_automation"

    // Save Workspace in new variable to pass to external Jenkinsfile
    withEnv (["BASE_WORKSPACE=${env.WORKSPACE}"]) {
        load 'build_automation/DeployTest/Jenkinsfile'
    }

    echo "ls -l"
	sh 'ls -l'

    echo "Clean Workspace: After execution"
    cleanWs()

    echo "ls -l"
	sh 'ls -l'
}