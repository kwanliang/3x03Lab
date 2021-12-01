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
                echo 'Testing Phase'
                sh 'composer install'

                sh './vendor/bin/phpunit --log-junit /var/jenkins_home/logs/tests/unit/${BUILD_NUMBER}_unitreport.xml -c tests/phpunit.xml tests'
            }
            
        }
    }
}