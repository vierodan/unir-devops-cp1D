pipeline {
    agent any
    stages {
        stage('Results') {
            steps {
                junit 'result*.xml'
                echo 'Finish'
            }
        }
    }
}