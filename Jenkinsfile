pipeline {
    agent{
        label 'agent1'
    }

    environment {
        AWS_REGION = 'us-east-1'
        STAGE = 'staging'
    }

    stages {
        stage('Static tests') {
            parallel {
                 stage('Static code'){
                    steps{
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {

                            sh """
                                echo 'STAGE --> Static code'
                                echo 'Host name:'; hostname
                                echo 'User:'; whoami
                                echo 'Workspace:'; pwd
                            """

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
                stage('Security code'){
                    steps{
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            sh """
                                echo 'STAGE --> Security code'
                                echo 'Host name:'; hostname
                                echo 'User:'; whoami
                                echo 'Workspace:'; pwd
                            """

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
        stage('Promote merge to master') {
            when {
                expression {
                    def result = currentBuild.result
                    if (result == null || result == 'SUCCESS') {
                        return true
                    } else {
                        echo 'Stage [Promote merge to master] skipped because Stage [Integration tests] fails'
                        return false
                    }
                }
            }
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    withCredentials([string(credentialsId: 'git_pat', variable: 'PAT')]) {
                        sh """
                            echo 'STAGE --> Promote merge to master'
                            echo 'Host name:'; hostname
                            echo 'User:'; whoami
                            echo 'Workspace:'; pwd
                        """

                        script {
                            // Setting Git configurations
                            sh "git config --global user.email 'vierodan@gmail.com'"
                            sh "git config --global user.name 'vierodan'"

                            // Performing Git operations 
                            sh '''
                                git checkout origin/master --Jenkinsfile
                                git pull https://\$PAT@github.com/vierodan/unir-devops-cp1D.git origin/master
                  
                                git fetch origin
                                git merge origin/develop || (git merge --abort && exit 1)

                                git push https://\$PAT@github.com/vierodan/unir-devops-cp1D.git origin/master

                            '''  
                        }
                    }
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