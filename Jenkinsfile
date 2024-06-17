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
                        --stack-name ${env.STACK_NAME} \
                        --region ${env.AWS_REGION} \
                        --capabilities CAPABILITY_IAM \
                        --parameter-overrides Stage=${env.STAGE} \
                        --no-fail-on-empty-changeset \
                        --s3-bucket ${env.S3_BUCKET} \
                        --s3-prefix ${env.S3_PREFIX} \
                        --no-confirm-changeset
                """
            }
        }
        stage('Extract Stack Outputs') {
            steps {
                script {

                    output = sh(script: '''#!/bin/bash
                        outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs')

                        extract_value() {
                            echo "$outputs" | jq -r ".[] | select(.OutputKey==\\"$1\\") | .OutputValue"
                        }

                        BASE_URL_API=$(extract_value "BaseUrlApi")
                        DELETE_TODO_API=$(extract_value "DeleteTodoApi")
                        LIST_TODOS_API=$(extract_value "ListTodosApi")
                        UPDATE_TODO_API=$(extract_value "UpdateTodoApi")
                        GET_TODO_API=$(extract_value "GetTodoApi")
                        CREATE_TODO_API=$(extract_value "CreateTodoApi")

                        cat <<EOF
                        export BASE_URL_API=$BASE_URL_API
                        export DELETE_TODO_API=$DELETE_TODO_API
                        export LIST_TODOS_API=$LIST_TODOS_API
                        export UPDATE_TODO_API=$UPDATE_TODO_API
                        export GET_TODO_API=$GET_TODO_API
                        export CREATE_TODO_API=$CREATE_TODO_API
                        EOF
                        ''', returnStdout: true).trim()
                    

                    envVars = output.split('\n')
                    envVars.each { envVar ->
                        def (key, value) = envVar.replace('export ', '').split('=')
                        env[key] = value
                    }
                    
                    echo "BASE_URL_API: ${env.BASE_URL_API}"
                    echo "DELETE_TODO_API: ${env.DELETE_TODO_API}"
                    echo "LIST_TODOS_API: ${env.LIST_TODOS_API}"
                    echo "UPDATE_TODO_API: ${env.UPDATE_TODO_API}"
                    echo "GET_TODO_API: ${env.GET_TODO_API}"
                    echo "CREATE_TODO_API: ${env.CREATE_TODO_API}"
                }
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