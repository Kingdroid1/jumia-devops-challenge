pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages{
        stage('Deploy Backend'){
            steps {
                 sh 'kubectl apply -f backend.yml'
            }
        }
        stage('Deploy Frontend'){
            steps {
                 sh 'kubectl apply -f frontend.yml'
            }
        }
            
    }
        
}
