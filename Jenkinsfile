def project = 'ci-cd-for-bn'
def appName = 'greenlight'
def imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"
if (env.BRANCH_NAME == "production") {
  kubeCloud = "production"
} else {
  kubeCloud = "staging"
}
podTemplate(label: label, cloud: "${kubeCloud}", containers: [
  containerTemplate(name: 'gccloud', image: 'gcr.io/ci-cd-for-bn/gcloud', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true)
]) 
{
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)

    stage('Build Build') {
      container('gccloud') {
            withCredentials([file(credentialsId: 'cloud-datastore-user-account-creds', variable: 'FILE')]) {
                sh "gcloud auth activate-service-account --key-file=$FILE"
                sh "gcloud docker -- build -t ${imageTag} . && gcloud docker -- push ${imageTag}"
            }
      }
    }

    stage('Run kubectl') {
      container('kubectl') {
         withCredentials([file(credentialsId: 'gl-launcher-staging-secrets', variable: 'FILE')]) {
            sh '''
              kubectl get pods && kubectl apply -f $FILE
            '''
         }
        sh "kubectl set image deployments/gl-deployment gl=${imageTag}"
      }
    }
    
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
    stage('Run helm') {
      container('helm') {
        sh "helm list"
      }
    }
  }
}
