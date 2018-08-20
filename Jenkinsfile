def project = 'ci-cd-for-bn'
def  appName = 'greenlight'
def  imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
def kubeCloud = ""
if (env.BRANCH_NAME == "production") {
  kubeCloud = "production"
} else {
  kubeCloud = "staging"
}

pipeline {
  agent {
    kubernetes {
      cloud kubeCloud
      label 'jenkins-gl-jenkins-deployer-slave'
      defaultContainer 'jnlp'
      yaml """
        apiVersion: v1
        kind: Pod
        metadata:
        labels:
          component: ci
        spec:
          serviceAccountName: default-edit
          containers:
          - name: gcloud
            image: gcr.io/cloud-builders/gcloud
            command:
            - cat
            tty: true
          - name: kubectl
            image: gcr.io/cloud-builders/kubectl
            command:
            - cat
            tty: true
      """
      }
  }
  stages {
    // stage('Test') {
    //   steps {
    //     container('golang') {
    //       sh """
    //         ln -s `pwd` /go/src/sample-app
    //         cd /go/src/sample-app
    //         go test
    //       """
    //     }
    //   }
    // }
    stage('Build and push image with Container Builder') {
      steps {
        container('gcloud') {
          sh "gcloud container builds submit -t ${imageTag} ."
        }
      }
    }
    stage('Deploy Greenlight Staging') {
      // Canary branch
      when { branch 'master' }
      steps {
        container('kubectl') {
          // Change deployed image in canary to the one we just built
          ///sh("sed -i.bak 's#gcr.io/${project}/${appName}#${imageTag}#' ./k8s/deployment.yaml")
          sh("kubectl set image deployments/gl-deployment gl=${imageTag}")
        } 
      }
    }
    // stage('Deploy Production') {
    //   // Production branch
    //   when { branch 'master' }
    //   steps{
    //     container('kubectl') {
    //     // Change deployed image in canary to the one we just built
    //       sh("sed -i.bak 's#gcr.io/cloud-solutions-images/gceme:1.0.0#${imageTag}#' ./k8s/production/*.yaml")
    //       sh("kubectl --namespace=production apply -f k8s/services/")
    //       sh("kubectl --namespace=production apply -f k8s/production/")
    //       sh("echo http://`kubectl --namespace=production get service/${feSvcName} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'` > ${feSvcName}")
    //     }
    //   }
    // }
    // stage('Deploy Dev') {
    //   // Developer Branches
    //   when { 
    //     not { branch 'master' } 
    //     not { branch 'canary' }
    //   } 
    //   steps {
    //     container('kubectl') {
    //       // Create namespace if it doesn't exist
    //       sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
    //       // Don't use public load balancing for development branches
    //       sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/services/frontend.yaml")
    //       sh("sed -i.bak 's#gcr.io/cloud-solutions-images/gceme:1.0.0#${imageTag}#' ./k8s/dev/*.yaml")
    //       sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
    //       sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
    //       echo 'To access your environment run `kubectl proxy`'
    //       echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${feSvcName}:80/"
    //     }
    //   }     
    // }
  }
}
