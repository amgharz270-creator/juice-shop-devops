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
        success {
            echo 'Pipeline executee avec succes'
        }
        failure {
            echo 'Echec de la pipeline'
        }
    }
}