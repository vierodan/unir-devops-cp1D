pipeline {
    agent{
        label 'agent2'
    }

    environment {
        AWS_REGION = 'us-east-1'
        STAGE = 'production'
    }

    stages {
        stage('Deploy'){
            steps{
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        echo 'STAGE --> Deploy'
                        echo 'Host name:'; hostname
                        echo 'User:'; whoami
                        echo 'Workspace:'; pwd
                    """

                    //sam build command
                    sh "sam build"

                    sleep(time: 1, unit: 'SECONDS')

                    //sam deploy command
                    sh "sam deploy \
                            --region ${env.AWS_REGION} \
                            --config-env ${env.STAGE} \
                            --template-file template.yaml \
                            --config-file samconfig.toml \
                            --no-fail-on-empty-changeset \
                            --no-confirm-changeset"
                }
            }
        }
        stage('Extract stack outputs') {
            //env variables for output endpoint from sam deploy command
            environment {
                ENDPOINT_BASE_URL_API = 'init'
            }
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        echo 'STAGE --> Extract stack outputs'
                        echo 'Host name:'; hostname
                        echo 'User:'; whoami
                        echo 'Workspace:'; pwd
                    """

                    echo "Value for --> STAGE: ${env.STAGE}"
                    echo "Value for --> AWS_REGION: ${env.AWS_REGION}"

                    script {
                        //asign permissions to execut scripts
                        sh "chmod +x get_base_url_api.sh"

                        //execute extract_output.sh script for extract outputs url's from sam deploy command
                        sh "./get_base_url_api.sh ${env.STAGE} ${env.AWS_REGION}"

                        //list temporal files created with url's for all endpoint
                        sh "ls -l *.tmp"

                        //read temporal files and asing the value to environment variable
                        def base_url = readFile('base_url_api.tmp').trim()
                        env.ENDPOINT_BASE_URL_API = "${base_url}"

                        //clean temporal files
                        sh "rm *.tmp"
                    }
                }
            }
        }
        stage('Integration tests') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        echo 'STAGE --> Integration tests'
                        echo 'Host name:'; hostname
                        echo 'User:'; whoami
                        echo 'Workspace:'; pwd
                    """


                    sh """
                        export BASE_URL=${env.ENDPOINT_BASE_URL_API}
                        pytest --junitxml=result-rest.xml test/integration/todoApiTest.py
                    """
                }
            }
        }
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
