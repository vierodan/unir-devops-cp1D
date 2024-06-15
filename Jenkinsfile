pipeline {
    agent any
    stages {
        stage('Static Code Analysis'){
            steps{
                sh hostname
                sh whoami
                sh echo %WORKSPACE%
                
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh flake8 --exit-zero --format=pylint --max-line-length=120 src > flake8.out
                    sh bandit --exit-zero -r src -f custom -o bandit.out --severity-level medium --msg-template "{abspath}:{line}: [{test_id}] {msg}"
                    
                    recordIssues(
                        tools: [flake8(name: 'Flake8', pattern: 'flake8.out')],
                        qualityGates: [
                            [threshold: 9999, type: 'TOTAL', unstable: false],
                            [threshold: 9999, type: 'TOTAL', unstable: true]
                        ]
                    )
                    
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
                    archiveArtifacts artifacts: 'flake8.out', allowEmptyArchive: true
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