def registry = 'https://shanaks.jfrog.io'
pipeline {
    agent {
        node {
            label 'maven'    
        }
    }
environment {
    PATH = "/opt/apache-maven-3.9.9/bin:$PATH"
}

    stages {
    	stage("build") {
	    steps {
	    	sh 'mvn clean deploy'
	    }
	  }

    // stage('SonarQube analysis') {
    // environment {
    //     scannerHome = tool 'akshat-sonar-scanner'
    //  } // must match the name of an actual scanner installation directory on your Jenkins build agent
    // steps{
    // withSonarQubeEnv('akshat-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name as configured in Jenkins
    //   sh "${scannerHome}/bin/sonar-scanner"
    //             }
    //         }
    // }

    // stage("Quality Gate"){
    //     steps {
    //         script {
    //             timeout(time: 1, unit: 'HOURS'){
    //                 def qg = waitForQualityGate()
    //                 if(qg.status != 'OK') {
    //                     error "Pipeline aborted due to quality gate failure: ${qg.status}"
    //                 }
    //             }
    //         }
    //     }
    // }

    

    stage("Jar Publish") {
        steps {
            script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"artifact-cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "mvn-libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
            }
        }   
    }

    }    
}