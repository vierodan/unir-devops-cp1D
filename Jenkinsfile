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
        BASE_URL_API = ''
        DELETE_TODO_API = ''
        LIST_TODOS_API = ''
        UPDATE_TODO_API = ''
        GET_TODO_API = ''
        CREATE_TODO_API = ''
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
                    // Execute AWS CLI command and capture output
                    def outputs = sh(
                        script: "aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs'",
                        returnStdout: true
                    ).trim()

                    // Define a function to extract value from JSON output
                    def extract_value(String key) {
                        return sh(
                            script: "echo '${outputs}' | jq -r '.[] | select(.OutputKey==\"${key}\") | .OutputValue'",
                            returnStdout: true
                        ).trim()
                    }

                    // Extract and assign values to environment variables
                    env.BASE_URL_API = extract_value("BaseUrlApi")
                    env.DELETE_TODO_API = extract_value("DeleteTodoApi")
                    env.LIST_TODOS_API = extract_value("ListTodosApi")
                    env.UPDATE_TODO_API = extract_value("UpdateTodoApi")
                    env.GET_TODO_API = extract_value("GetTodoApi")
                    env.CREATE_TODO_API = extract_value("CreateTodoApi")
                }

                // Print values (optional, for verification)
                sh """
                    echo 'Base URL of API: \${BASE_URL_API}'
                    echo 'Delete TODO API: \${DELETE_TODO_API}'
                    echo 'List TODOs API: \${LIST_TODOS_API}'
                    echo 'Update TODO API: \${UPDATE_TODO_API}'
                    echo 'Get TODO API: \${GET_TODO_API}'
                    echo 'Create TODO API: \${CREATE_TODO_API}'
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