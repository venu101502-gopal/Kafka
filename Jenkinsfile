pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_WORKING_DIR        = '.'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    sh 'terraform plan -out=tfplan -input=false'
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Review Plan') {
            when {
                expression { return !params.autoApprove }
            }
            steps {
                script {
                    def planText = readFile('tfplan.txt')
                    input message: "Do you want to apply the Terraform plan?", parameters: [
                        text(name: 'Plan', description: 'Terraform plan preview', defaultValue: planText)
                    ]
                }
            }
        }

        stage('Terraform Apply') {
            when {
                anyOf {
                    expression { return params.autoApprove }
                    expression { return !params.autoApprove }
                }
            }
            steps {
                dir("${TF_WORKING_DIR}") {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            dir("${TF_WORKING_DIR}") {
                sh 'terraform fmt -check || echo "Terraform files not properly formatted."'
            }
        }
        failure {
            echo 'Pipeline failed.'
        }
        success {
            echo 'Terraform apply completed successfully!'
        }
    }
}
