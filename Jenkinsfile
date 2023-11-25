#!/usr/bin/env groovy

pipeline {
    agent any
    tools {
        maven 'maven-3.9' 
    }

stages {
        stage("Downloading terraform file.....") {
            steps {
                script {
                    echo 'downloading terraform files ...'
                    sh "bash ./config.sh ${action}"
                }
            }
        }  
}
}
