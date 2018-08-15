pipeline {
    agent {
        docker {
            image 'node:6-alpine'
            args '-p 3000:3000 -p 5000:5000' 
        }
    }
    environment {
        CI = 'true'
    }
    stages {
        stage('Build') {
            steps {
                env.DOCKER_API_VERSION="1.23"
  
                sh "git rev-parse --short HEAD > commit-id"
           
                tag = readFile('commit-id').replace("\n", "").replace("\r", "")
                withCredentials([string(credentialsId: 'DOCKER_USER', variable: '	DOCKER_USER')]) {
                    appName = "$DOCKER_USER\\/greenlight"
                }

                imageName = "${appName}:${tag}"
                env.BUILDIMG=imageName
                sh "docker build -t ${imageName} ."
            }
        }
        stage('Push') {
            steps {
                  withCredentials([string(credentialsId: 'DOCKER_USER', variable: '	DOCKER_USER'), string(credentialsId: 'DOCKER_EMAIL', variable: 'DOCKER_EMAIL'), string(credentialsId: 'DOCKER_PASSWORD', variable: 'DOCKER_PASSWORD')]) {
                      sh '''
                         set +x
                         docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASSWORD
                         set -x 
                      '''
                  }
                  sh "docker push ${imageName}"
            }
        }
        stage('Deploy') {
             withCredentials([string(credentialsId: 'DOCKER_USER', variable: '	DOCKER_USER')]) {
                sh '''
                 sed "s/^\\s*image: $DOCKER_USER\\/greenlight:.*/    image: $BUILDIMG/g" deployment.yaml | kubectl apply -f -
               '''
             }
        }
    }
}
