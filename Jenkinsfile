pipeline {

    agent any

    environment { 
        CI = 'true'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building phase'       
            }
        }

        stage('Dependency Check'){
            steps {
                echo 'Initializing OWASP Dependency Check'
                dependencyCheck additionalArguments: '--format HTML --format XML --out /var/lib/docker/volumes/jenkins-data/_data/logs/dependency_check/${BUILD_NUMBER}', odcInstallation: 'Dependency-Check'
            }
            
            post {
                always {
                    sh 'cp /var/lib/docker/volumes/jenkins-data/_data/logs/dependency_check/${BUILD_NUMBER}/dependency-check-report.xml ${WORKSPACE}'
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                }
            }
        }

        stage('Unit Test') {
            agent {
                docker {
                    image 'composer:latest'
                }
            }
                    
            steps {
                sh 'composer install'
                echo 'Testing Phase'
                sh './vendor/bin/phpunit --log-junit /var/lib/docker/volumes/jenkins-data/_data/logs/tests/unit/${BUILD_NUMBER}_unitreport.xml -c tests/phpunit.xml tests'
            }
            
            post {
                always {
                    sh 'cp /var/lib/docker/volumes/jenkins-data/_data/logs/tests/unit/${BUILD_NUMBER}_unitreport.xml ${WORKSPACE}'
                    junit testResults: '*.xml'
                }
            }
        }
    }
}