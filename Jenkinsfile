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
                dependencyCheck additionalArguments: '--format HTML --format XML', odcInstallation: 'dep'
            }
            
            post {
                always {
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
                sh './vendor/bin/phpunit --log-junit logs/unitreport.xml -c tests/phpunit.xml tests'
            }
            
            post {
                always {
                    junit testResults: 'logs/unitreport.xml'
                }
            }
        }
    }
}