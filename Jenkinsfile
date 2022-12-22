pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    node {
        stage('Install kubectl') {
            withKubeConfig([credentialsId: 'kubernetes-config']) {
                sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.20.5/bin/linux/amd64/kubectl"'  
                sh 'chmod u+x ./kubectl'
            }
        }
    }
    stages{
        stage('Deploy Backend'){
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
