pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages{
        stage('Deploy'){
            steps {
                 sh 'kubectl apply -f backend.yml',
                 sh 'kubectl apply -f frontend.yml'
            }
        }
    }
        
}
