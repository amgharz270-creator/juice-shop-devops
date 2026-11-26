
pipeline {
    agent any

    stages {
        stage('Verification du code source') {
            steps {
                echo 'Connexion Jenkins-GitHub reussie'
                sh 'git rev-parse HEAD'
                sh 'test -f package.json'
            }
        }

        stage('Initialisation DevSecOps') {
            steps {
                echo 'Pipeline DevSecOps initialisee'
            }
        }
    }

    post {
        always {
            script {
                def status = currentBuild.currentResult

                echo "Statut du build : ${status}"

                def message = groovy.json.JsonOutput.toJson([
                    username: 'Jenkins DevSecOps',
                    content: """Projet : OWASP Juice Shop
Pipeline : ${env.JOB_NAME}
Build : #${env.BUILD_NUMBER}
Statut : ${status}
Branche : ${env.GIT_BRANCH}"""
                ])

                writeFile file: 'discord-payload.json', text: message

                try {
                    withCredentials([
                        string(
                            credentialsId: 'discord-webhook',
                            variable: 'DISCORD_WEBHOOK'
                        )
                    ]) {
                        sh '''
                            set +x
                            curl --fail --silent \
                                --max-time 30 \
                                -H "Content-Type: application/json" \
                                --data-binary @discord-payload.json \
                                "$DISCORD_WEBHOOK" > /dev/null 2>&1
                        '''
                    }

                    echo 'Notification Discord envoyee'
                } catch (Exception e) {
                    echo 'Echec de la notification Discord'
                }
            }
        }

        success {
            echo 'Pipeline executee avec succes'
        }

        failure {
            echo 'Echec de la pipeline'
        }
    }
}
