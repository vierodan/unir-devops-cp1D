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
        BASE_URL_API = 'init'
        DELETE_TODO_API = 'init'
        LIST_TODOS_API = 'init'
        UPDATE_TODO_API = 'init'
        GET_TODO_API = 'init'
        CREATE_TODO_API = 'init'
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
                    sh 'ls -l *.tmp'
                }
            }
        }
        stage('Asign env variables') {
            steps {
                script {
                    sh 'chmod +x base_url_api.tmp'
                    sh 'chmod +x delete_todo_api.tmp'
                    sh 'chmod +x list_todos_api.tmp'
                    sh 'chmod +x update_todo_api.tmp'
                    sh 'chmod +x get_todo_api.tmp'
                    sh 'chmod +x create_todo_api.tmp'


                    try {
                        env.BASE_URL_API = readFile('base_url_api.tmp').trim()
                        env.DELETE_TODO_API = readFile('delete_todo_api.tmp').trim()
                        env.LIST_TODOS_API = readFile('list_todos_api.tmp').trim()
                        env.UPDATE_TODO_API = readFile('update_todo_api.tmp').trim()
                        env.GET_TODO_API = readFile('get_todo_api.tmp').trim()
                        env.CREATE_TODO_API = readFile('create_todo_api.tmp').trim()
                    } catch (Exception e) {
                        echo "Error when asign environment variables: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error "Unable asign environment variables"
                    }
                }


            }
        }
        stage('tes variables'){
            steps{
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