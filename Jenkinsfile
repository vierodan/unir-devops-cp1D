pipeline {
    agent any
    stages {
        stage('Static Analysis') {
            parallel {
                 stage('Static Code'){
                    steps{
                        sh '''
                            hostname
                            whoami
                            echo WORKSPACE
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
                    post {
                        always {
                            archiveArtifacts artifacts: 'flake8.out', allowEmptyArchive: true
                        }
                    }
                }
                stage('Security Code'){
                    steps{
                        sh '''
                            hostname
                            whoami
                            echo WORKSPACE
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
                    post {
                        always {
                            archiveArtifacts artifacts: 'bandit.out', allowEmptyArchive: true
                        }
                    }
                }
            }
        }
        stage('Results') {
            steps {
                sleep(time: 5, unit: 'SECONDS')
                junit 'result*.xml'
                echo 'Finish'
            }
        }
    }
}