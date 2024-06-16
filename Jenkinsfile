pipeline {
    agent{
        label 'agent1'
    }

    environment {
        AWS_REGION = 'us-east-1'
        STACK_NAME = 'todo-list-aws-staging'
        S3_BUCKET = 'aws-sam-cli-managed-default-samclisourcebucket-hwr6ts9w4rff'
        S3_PREFIX = 'staging'
        STAGE = 'staging'
    }

    stages {
        stage('Static Analysis') {
            parallel {
                 stage('Static Code'){
                    steps{
                        sh """
                            echo 'Host name, User and Workspace'
                            hostname
                            whoami
                            pwd
                        """
                        
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            sh """
                                flake8 --exit-zero --format=pylint --max-line-length=120 src > flake8.out
                            """
                            
                            recordIssues(
                                tools: [flake8(name: 'Flake8', pattern: 'flake8.out')],
                                qualityGates: [
                                    [threshold: 9999, type: 'TOTAL', unstable: false],
                                    [threshold: 9999, type: 'TOTAL', unstable: true]
                                ]
                            )
                        }
                    }
                }
                stage('Security Code'){
                    steps{
                        sh '''
                            echo 'Host name, User and Workspace'
                            hostname
                            whoami
                            pwd
                        '''
                        
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            sh '''
                                bandit --exit-zero -r src -f custom -o bandit.out --severity-level medium --msg-template "{abspath}:{line}: [{test_id}] {msg}"
                            '''
                            
                            recordIssues( 
                                tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')], 
                                qualityGates:[
                                    [threshold: 9999, type: 'TOTAL', unstable: true], 
                                    [threshold: 9999, type: 'TOTAL', unstable: false]
                                ]
                            )
                            
                        }
                    }
                }
            }
        }
        stage('Deploy'){
            steps{
                sh """
                    sam build
                """
                sleep(time: 1, unit: 'SECONDS')

                sh """
                    sam deploy \
                        --template-file template.yaml \
                        --stack-name ${STACK_NAME} \
                        --region ${AWS_REGION} \
                        --capabilities CAPABILITY_IAM \
                        --parameter-overrides Stage=${STAGE} \
                        --no-fail-on-empty-changeset \
                        --s3-bucket ${S3_BUCKET} \
                        --s3-prefix ${S3_PREFIX} \
                        --no-confirm-changeset
                """
            }
        }
        stage('Extract Stack Outputs') {
            steps {
                script {
                    sh 'chmod +x extract_outputs.sh'
                    sh './extract_outputs.sh'
                }

                sh """
                    echo 'Base URL of API: ${BASE_URL_API}'
                    echo 'Delete TODO API: ${DELETE_TODO_API}'
                    echo 'List TODOs API: ${LIST_TODOS_API}'
                    echo 'Update TODO API: ${UPDATE_TODO_API}'
                    echo 'Get TODO API: ${GET_TODO_API}'
                    echo 'Create TODO API: ${CREATE_TODO_API}'
                """
            }
        }
        stage('Results') {
            steps {
                sh """
                    echo 'Finish'
                """
            }
        }
    }
}