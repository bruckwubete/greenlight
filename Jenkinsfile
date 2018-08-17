def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, cloud: 'greenlight-cluster', containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
    
    stage('Build') {
        container('docker')  {
            withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER')]) {
                 sh "docker build -t '$DOCKER_USER/greenlight:${gitCommit}' ."
            }
        }
    }
    stage('Push') {
        container('docker') {
              withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER'), string(credentialsId: 'DOCKER_EMAIL', variable: 'DOCKER_EMAIL'), string(credentialsId: 'DOCKER_PASSWORD', variable: 'DOCKER_PASSWORD')]) {
                  sh '''
                     docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
                  '''
                  sh "docker push '$DOCKER_USER/greenlight:${gitCommit}'"
              }
        }
    }
    stage('Deploy') {
        container('docker') {
             withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER')]) {
                // sh '''
               //  sed "s/^\\s*image: $DOCKER_USER\\/greenlight:.*/    image: $DOCKER_USER\\/greenlight:${gitCommit}/g" deployment.yaml | kubectl apply -f -
               // '''
             }
        }
    }
    stage('Run kubectl') {
      container('kubectl') {
         withCredentials([file(credentialsId: 'gl-launcher-staging-secrets', variable: 'gl-launcher-staging-secrets')]) {
            sh '''
              kubectl apply -f \$gl-launcher-staging-secrets
            '''
         }
        sh "kubectl get pods"
      }
    }
    stage('Run helm') {
      container('helm') {
        sh "helm list"
      }
    }
  }
}
