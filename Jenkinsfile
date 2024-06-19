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
            }
            steps {

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
        stage('Api Integration Tests') {
            steps {
                sh """
                    echo 'Host name, User and Workspace'
                    hostname
                    whoami
                    pwd
                """
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        export BASE_URL=${env.ENDPOINT_BASE_URL_API}
                        pytest --junitxml=result-rest.xml test/integration/todoApiTest.py
                    """
                }
            }
        }
        stage('Merge to Master') {
            steps {
                sh """
                    echo 'Host name, User and Workspace'
                    hostname
                    whoami
                    pwd
                """

                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                        withCredentials([string(credentialsId: 'git_pat', variable: 'PAT')]) {
                                sh """
                                    git config --global user.email "vierodan@gmail.com"
                                    git config --global user.name "vierodan"

                                    git checkout -- .
                                    git checkout master
                                    git pull https://$PAT@github.com/vierodan/unir-devops-cp1D.git master
                                    git fetch origin
                                    git merge origin/develop || (git merge --abort && exit 1)
                                    git push https://$PAT@github.com/vierodan/unir-devops-cp1D.git master
                                """
                        }
                    }
                }
            }
        }
        stage('Results') {
            steps {
                sleep(time: 5, unit: 'SECONDS')
                junit 'result*.xml'
            }
            post {
                success {
                    echo 'Pipeline completed successfully.'
                }
                failure {
                    echo 'Pipeline failed.'
                }
            }
        }
    }
}