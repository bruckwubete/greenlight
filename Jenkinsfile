pipeline {
    agent {
        docker {
            image 'gcr.io/cloud-solutions-images/jenkins-k8s-slave'
        }
    }
    environment {

        CI = 'true'
    }
    
    stages {
        stage('Build') {
            steps {
                withCredentials([string(credentialsId: 'DOCKER_USER', variable: '	DOCKER_USER')]) {
                     sh "git rev-parse --short HEAD > commit-id"
                     script {
                         env.tag = readFile('commit-id').replace("\n", "").replace("\r", "")
                     }
                     sh "docker build -t '$DOCKER_USER\\/greenlight:$tag' ."
                }
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
            steps {
                 withCredentials([string(credentialsId: 'DOCKER_USER', variable: '	DOCKER_USER')]) {
                    sh '''
                     sed "s/^\\s*image: $DOCKER_USER\\/greenlight:.*/    image: $DOCKER_USER\\/greenlight:$tag/g" deployment.yaml | kubectl apply -f -
                   '''
                 }
            }
        }
    }
}
