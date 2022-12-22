pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages{
        stage('Deploy Backend'){
            steps {
            withKubeConfig([credentialsId: 'kubernetes-config']) {
                sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.22.0/bin/linux/amd64/kubectl"'  
                sh 'chmod u+x ./kubectl'  
                sh './kubectl get pods'
            }
            }
            steps {
                 sh './kubectl apply -f backend.yml'
            }
        }
        stage('Deploy Frontend'){
            steps {
                 sh './kubectl apply -f frontend.yml'
            }
        }
            
    }
        
}
