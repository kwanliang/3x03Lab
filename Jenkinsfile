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

        agent {
            docker {
                image 'composer:latest'
            }
        }

        stage('Unit Test') {

                    
            steps {
                sh 'composer install'
                echo 'Testing Phase'
                sh './vendor/bin/phpunit --log-junit logs/unitreport.xml -c tests/phpunit.xml tests'
            }
            
        }
    }
}