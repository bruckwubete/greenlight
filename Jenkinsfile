def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
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
    
    stages {
        stage('Build') {
            steps {
                withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER')]) {
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
                  withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER'), string(credentialsId: 'DOCKER_EMAIL', variable: 'DOCKER_EMAIL'), string(credentialsId: 'DOCKER_PASSWORD', variable: 'DOCKER_PASSWORD')]) {
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
                 withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER')]) {
                    sh '''
                     sed "s/^\\s*image: $DOCKER_USER\\/greenlight:.*/    image: $DOCKER_USER\\/greenlight:$tag/g" deployment.yaml | kubectl apply -f -
                   '''
                 }
            }
        }
    }
  }
}
