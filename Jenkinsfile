pipeline {
    agent none
    stages {
        stage ('Terrafrom init') {
            sh "terraform init -input=false"
        }

        stage ('Terrafrom plan') {
            exitCode = sh (
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
        }

        if (currentBuild.result == 'SUCCESS') {
            return
        }

        input message:"Deploy plan ${BUILD_NUMBER}.tfplan ?"

        stage ('Terrafrom apply') {
            sh "terraform apply -input=false ${BUILD_NUMBER}.tfplan"
        }
    }
}