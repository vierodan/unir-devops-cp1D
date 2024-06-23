pipeline {
    agent{
        label 'agent1'
    }

    environment {
        AWS_REGION = 'us-east-1'
        STAGE = 'production'
    }

    stages {

    }
    post {
        always {
             junit 'result*.xml'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        unstable {
            echo 'Pipeline failed.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
