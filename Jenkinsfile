node {
    checkout scm
}

pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr:'10'))
        timeout(time: 5, unit: 'MINUTES')
        ansiColor('xterm')
    }

    stages {        
        stage ('Terrafrom init') {
            steps {
                dir('examples/networking') {
                    sh "terraform init -input=false -backend-config=\"bucket=${params.tf-state-bucket-name}\" -backend-config=\"region=${params.tf-state-bucket-region}\""
                }
            }
        }

        stage ('Terrafrom plan') {
            steps {
                dir('examples/networking') {
                    script {
                        def exitCode = sh (
                                script: "terraform plan -out=${BUILD_NUMBER}.tfplan -input=false -detailed-exitcode",
                                returnStatus: true
                            )
                        switch(exitCode) {
                                case 0:
                                    echo 'Plan OK with no changes'
                                    currentBuild.result = 'SUCCESS'
                                    break
                                case 1:
                                    echo 'Plan Failed'
                                    currentBuild.result = 'FAILURE'
                                    break
                                case 2:
                                    echo 'Plan OK with changes: proceeding'
                                    break
                        }
                        if (currentBuild.result == 'SUCCESS') {
                            return
                        }
                        def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                    }
                }
            }
        }

        stage ('Terrafrom apply') {
            steps {
                dir('examples/networking') {
                    sh "terraform apply -input=false ${BUILD_NUMBER}.tfplan"
                }
            }
        }
    }
}