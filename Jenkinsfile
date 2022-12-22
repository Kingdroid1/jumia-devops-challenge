pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
        stage('Deploy'){
            steps {
                 sh 'kubectl apply -f backend.yml',
                 sh 'kubectl apply -f frontend.yml'
            }
        }
}
