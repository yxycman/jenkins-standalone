node {
    checkout scm
}

pipeline {
    agent any
    stages {
        stage ('Terrafrom init') {
            steps {
                sh "terraform init -input=false"
            }
        }

        stage ('Terrafrom plan') {
            steps {

                sh "terraform plan -out=${BUILD_NUMBER}.tfplan -input=false -detailed-exitcode"
                script {
                    def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                }
            }
        }

        //if (currentBuild.result == 'SUCCESS') {
        //    return
        //}

        //input message:"Deploy plan ${BUILD_NUMBER}.tfplan ?"

        stage ('Terrafrom apply') {
            steps {
                sh "terraform apply -input=false ${BUILD_NUMBER}.tfplan"
            }
        }
    }
}