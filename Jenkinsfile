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
                                    [threshold: 8, type: 'TOTAL', unstable: false],
                                    [threshold: 10, type: 'TOTAL', unstable: true]
                                ]
                            )
                        }
                    }
                }
                stage('Security Code'){
                    steps{
                        sh '''
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
                                    [threshold: 3, type: 'TOTAL', unstable: true], 
                                    [threshold: 4, type: 'TOTAL', unstable: false]
                                ]
                            )
                            
                        }
                    }
                }
            }
        }
        stage('Results') {
            steps {
                sleep(time: 5, unit: 'SECONDS')
                echo 'Finish'
            }
        }
    }
}