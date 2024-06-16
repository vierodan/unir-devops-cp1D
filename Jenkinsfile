pipeline {
    agent{
        label 'agent1'
    }
    stages {
        stage('Static Analysis') {
            parallel {
                 stage('Static Code'){
                    steps{
                        sh '''
                            echo 'Host name, User and Workspace'
                            hostname
                            whoami
                            pwd
                        '''
                        
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            sh '''
                                flake8 --exit-zero --format=pylint --max-line-length=120 src > flake8.out
                            '''
                            
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
                sh '''
                    sam build
                '''
                sleep(time: 1, unit: 'SECONDS')

                sh '''
                    sam deploy \
                        --template-file template.yaml \
                        --stack-name todo-list-aws-staging \
                        --region us-east-1 \
                        --capabilities CAPABILITY_IAM \
                        --parameter-overrides Stage=staging \
                        --no-fail-on-empty-changeset \
                        --s3-bucket aws-sam-cli-managed-default-samclisourcebucket-hwr6ts9w4rff \
                        --s3-prefix staging \
                        --no-confirm-changeset
                '''
                 sleep(time: 1, unit: 'SECONDS')

                sh '''
                    outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs')

                    my_function_arn=$(echo $outputs | jq -r '.[] | select(.OutputKey=="MyFunctionArn") | .OutputValue')
                    my_api_endpoint=$(echo $outputs | jq -r '.[] | select(.OutputKey=="MyApiEndpoint") | .OutputValue')

                    echo "Function ARN: $my_function_arn"
                    echo "API Endpoint: $my_api_endpoint"

                '''

            }
        }
        stage('Results') {
            steps {
                sh '''
                    junit 'result*.xml'
                    echo 'Finish'
                '''
            }
        }
    }
}