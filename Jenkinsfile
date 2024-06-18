pipeline {
    agent{
        label 'agent1'
    }

    //
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
                            sh "flake8 \
                                    --exit-zero \
                                    --format=pylint \
                                    --max-line-length=120 \
                                    src > flake8.out"
                            
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
                        sh """
                            echo 'Host name, User and Workspace'
                            hostname
                            whoami
                            pwd
                        """
                        
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            sh "bandit \
                                    --exit-zero \
                                    -r src \
                                    -f custom \
                                    -o bandit.out \
                                    --severity-level medium \
                                    --msg-template '{abspath}:{line}: [{test_id}] {msg}'"
                            
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
                //sam build command
                sh "sam build"

                sleep(time: 1, unit: 'SECONDS')

                //sam deploy command
                sh "sam deploy \
                        --template-file template.yaml \
                        --stack-name ${env.STACK_NAME} \
                        --region ${env.AWS_REGION} \
                        --capabilities CAPABILITY_IAM \
                        --parameter-overrides Stage=${env.STAGE} \
                        --no-fail-on-empty-changeset \
                        --s3-bucket ${env.S3_BUCKET} \
                        --s3-prefix ${env.S3_PREFIX} \
                        --no-confirm-changeset"
            }
        }
        stage('Extract Stack Outputs') {
            //env variables for output endpoint from sam deploy command
            environment {
                ENDPOINT_BASE_URL_API = 'init'
                ENDPOINT_DELETE_TODO_API = 'init'
                ENDPOINT_LIST_TODOS_API = 'init'
                ENDPOINT_UPDATE_TODO_API = 'init'
                ENDPOINT_GET_TODO_API = 'init'
                ENDPOINT_CREATE_TODO_API = 'init'
            }
            steps {

                echo "Value for --> STAGE: ${env.STAGE}"
                echo "Value for --> AWS_REGION: ${env.AWS_REGION}"

                script {
                    //asign permissions to execut scripts
                    sh "chmod +x extract_outputs.sh"
                    sh "chmod +x cut_tmp_file.sh"

                    //execute extract_output.sh script for extract outputs url's from sam deploy command
                    sh "./extract_outputs.sh ${env.STAGE} ${env.AWS_REGION}"

                    //list temporal files created with url's for all endpoint
                    sh "ls -l *.tmp"

                    sleep time: 3, unit: 'SECONDS'

                    def executeCutTmpFile = { content, cut ->
                        def result = sh(
                            script: "./cut_tmp_file.sh ${content} ${cut}",
                            returnStdout: true
                        ).trim()
                        
                        return result
                    }

                    def url_from_file = readFile('delete_todo_api.tmp').trim()
                    def result_cut = executeCutTmpFile(${url_from_file}, 4)
                    env.ENDPOINT_DELETE_TODO_API = ${result_cut}

                    sleep time: 3, unit: 'SECONDS'

                    //read temporal files and asing the value to environment variable
                    //env.ENDPOINT_BASE_URL_API = readFile('base_url_api.tmp').trim()
                    //env.ENDPOINT_DELETE_TODO_API = readFile('delete_todo_api.tmp').trim()
                    //env.ENDPOINT_LIST_TODOS_API = readFile('list_todos_api.tmp').trim()
                    //env.ENDPOINT_UPDATE_TODO_API = readFile('update_todo_api.tmp').trim()
                    //env.ENDPOINT_GET_TODO_API = readFile('get_todo_api.tmp').trim()
                    //env.ENDPOINT_CREATE_TODO_API = readFile('create_todo_api.tmp').trim()

                    //clean temporal files
                    //sh "rm *.tmp"
                }
            }
        }
        stage('test variables'){
            steps{
                echo "Value for --> ENDPOINT_BASE_URL_API: ${env.ENDPOINT_BASE_URL_API}"
                echo "Value for --> ENDPOINT_DELETE_TODO_API: ${env.ENDPOINT_DELETE_TODO_API}"
                echo "Value for --> ENDPOINT_LIST_TODOS_API: ${env.ENDPOINT_LIST_TODOS_API}"
                echo "Value for --> ENDPOINT_UPDATE_TODO_API: ${env.ENDPOINT_UPDATE_TODO_API}"
                echo "Value for --> ENDPOINT_GET_TODO_API: ${env.ENDPOINT_GET_TODO_API}"
                echo "Value for --> ENDPOINT_CREATE_TODO_API: ${env.ENDPOINT_CREATE_TODO_API}"
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