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

        stage('Dependency Check') {
            steps {
                echo 'Initializing OWASP Dependency Check'
                dependencyCheck additionalArguments: '--format HTML --format XML --suppression suppression.xml', odcInstallation: 'Dependency-Check'
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
                sh './vendor/bin/phpunit --log-junit /var/jenkins_home/logs/tests/unit/${BUILD_NUMBER}_unitreport.xml -c tests/phpunit.xml tests'
            }
            
            post {
                always {
                    sh 'cp /var/jenkins_home/logs/tests/unit/${BUILD_NUMBER}_unitreport.xml ${WORKSPACE}'
                    junit testResults: '*.xml'
                }
            }
        }
        
        stage('Integration UI Test') {
			parallel {
				stage('Deploy') {
					agent any
					steps {
                        sh 'chmod +x ./jenkins/scripts/deploy.sh'
						sh './jenkins/scripts/deploy.sh'
					}
				}
				stage('Headless Browser Test') {
					agent {
						docker {
							image 'maven:3-alpine' 
							args '-v /root/.m2:/root/.m2' 
						}
					}
					steps {
						sh 'mvn -B -DskipTests clean package'
						sh 'mvn test'
					}
					post {
						success {
							junit 'target/surefire-reports/*.xml'
						}
					}
				}
                stage('Kill') {
					agent any
					steps {
                        sh 'chmod +x ./jenkins/scripts/kill.sh'
                        sh './jenkins/scripts/kill.sh'
					}
				}
			}
		}
        
        
        stage('Warnings Analysis') {
			parallel {
                stage('Checkout') {
                    steps {
                        git branch:'master', url: 'https://github.com/ScaleSec/vulnado.git'
                    }
                }
                stage ('Build') {
                    steps {
                        sh '/var/jenkins_home/apache-maven-3.6.3/bin/mvn --batch-mode -V -U -e clean verify -Dsurefire.useFile=false -Dmaven.test.failure.ignore'
                    }
                }
                stage ('Analysis') {
                    steps {
                        sh '/var/jenkins_home/apache-maven-3.6.3/bin/mvn --batch-mode -V -U -e checkstyle:checkstyle pmd:pmd pmd:cpd findbugs:findbugs'
                    }
                    
                    post {
                        always {
                            junit testResults: '**/target/surefire-reports/TEST-*.xml'
                            recordIssues enabledForFailure: true, tools: [mavenConsole(), java(), javaDoc()]
                            recordIssues enabledForFailure: true, tool: checkStyle()
                            recordIssues enabledForFailure: true, tool: spotBugs(pattern: '**/target/findbugsXml.xml')
                            recordIssues enabledForFailure: true, tool: cpd(pattern: '**/target/cpd.xml')
                            recordIssues enabledForFailure: true, tool: pmdParser(pattern: '**/target/pmd.xml')
                        }
                    }
                }
            }
        }
        
        stage('SonarQube') {
			parallel {
                stage('Checkout') {
                    steps {
                        git branch:'master', url: 'https://github.com/OWASP/Vulnerable-Web-Application.git'
                    }
                }
                stage('Analysis') {
                    steps {
                        script {
                            def scannerHome = tool 'SonarQube';
                            withSonarQubeEnv('SonarQube') {
                                sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=OWASP -Dsonar.sources=. -Dsonar.host.url=http://192.168.116.132:9000 -Dsonar.login=bda8ff3be128888a5098f7c3cdfcb63291d2dbf0"
                            }
                        }
                    }
                    post {
                        always {
                            recordIssues enabledForFailure: true, tool: sonarQube()
                        }
                    }
                }
            }
        }
    }
}