def project = 'ci-cd-for-bn'
def appName = 'greenlight'
def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"
if (env.BRANCH_NAME == "production") {
  kubeCloud = "production"
} else {
  kubeCloud = "staging"
}
podTemplate(label: label, cloud: "${kubeCloud}", containers: [
  containerTemplate(name: 'gcloud', image: 'lakoo/node-gcloud-docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]){
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
    def imageTag = "gcr.io/${project}/${appName}:${gitBranch}.${env.BUILD_NUMBER}.${gitCommit}"

    stage('Build and Publish') {
      container('gcloud') {
            withCredentials([file(credentialsId: 'cloud-datastore-user-account-creds', variable: 'FILE')]) {
                sh "gcloud auth activate-service-account --key-file=$FILE"
                sh "gcloud docker -- build -t ${imageTag} . && gcloud docker -- push ${imageTag}"
            }
      }
    }

    stage('Deploy') {
      container('kubectl') {
         withCredentials([file(credentialsId: 'gl-launcher-staging-secrets', variable: 'FILE')]) {
            sh '''
              kubectl get pods && kubectl apply -f $FILE
            '''
         }
        sh "kubectl set image deployments/gl-deployment gl=${imageTag}"
      }
    }
  }
}
