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
                    sh 'chmod +x extract_outputs.sh'
                    sh './extract_outputs.sh'
                }
            }
        }
        stage('Asign env variables'){
            steps{
                script{
                    env.BASE_URL_API = readFile('base_url_api.tmp').trim()
                    env.DELETE_TODO_API = readFile('delete_todo_api.tmp').trim();
                }

                echo "Value for --> BASE_URL_API es: ${env.BASE_URL_API}"
                echo "Value for --> DELETE_TODO_API es: ${env.DELETE_TODO_API}"
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