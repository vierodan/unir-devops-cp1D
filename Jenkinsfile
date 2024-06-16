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
        stage('Results') {
            steps {
                echo 'Finish'
            }
        }
    }
}