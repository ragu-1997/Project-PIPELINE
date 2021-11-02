node('UAT-windows') {
    try {
	

stage('service stop')
{
  node('master'){
    // Run the job in master jenkins
      stage('playbook-checkout')
      {
        // clean the current workspace and checkout the code from Devops repository
          cleanWs() 
checkout([$class: 'SubversionSCM', additionalCredentials: [], excludedCommitMessages: '', excludedRegions: '', excludedRevprop: '', excludedUsers: '', filterChangelog: false, ignoreDirPropChanges: false, includedRegions: '', locations: [[cancelProcessOnExternalsFail: true, credentialsId: '585fa701-720a-4602-abe6-b977c8773a4c', depthOption: 'infinity', ignoreExternalsOption: true, local: '.', remote: 'https://192.168.1.200/svn/CloudBLM-DevOps/deployment/windows-playbook/UAT-Ansible/EmailService']], quietOperation: true, workspaceUpdater: [$class: 'UpdateUpdater']])      
}
      stage('Stop IIS website')
      {
        // Stop the IIS service via ansible
        sh 'ansible-playbook EmailService-stop.yml'
      }
  }
}

node('UAT-windows'){
  // Run the job in slave jenkins
stage('checkout from CBLM repo') 
{
  // clean the current workspace and checkout the code from CBLM repository
    cleanWs()

checkout([$class: 'SubversionSCM', additionalCredentials: [], excludedCommitMessages: '', excludedRegions: '', excludedRevprop: '', excludedUsers: '', filterChangelog: false, ignoreDirPropChanges: false, includedRegions: '', locations: [[cancelProcessOnExternalsFail: true, credentialsId: '585fa701-720a-4602-abe6-b977c8773a4c', depthOption: 'infinity', ignoreExternalsOption: true, local: '.', remote: 'https://192.168.1.200/svn/API/Products/Cloud BLM/Application/branches/Experimental branch/BackEnd Services- Unified Database/CloudBLM-EmailNotification']], quietOperation: true, workspaceUpdater: [$class: 'UpdateUpdater']])}

stage('Remove obj')
{
  //Remove the object file 

               bat 'del /Q BusinessLogic\\obj'
               bat 'del /Q DatabaseLogic\\obj'
               bat 'del /Q EmailNotification\\obj'
               bat 'del /Q IBusinessLogic\\obj'
               bat 'del /Q IDatabaseLogic\\obj'
               bat 'del /Q Models\\obj'
}
stage('clean')
{
    bat 'dotnet clean'
}
stage('build')
{
    bat 'dotnet build'
}

stage('publish')
{
  //publish and delete the working dir in jenkins
   bat 'dotnet publish EmailNotification.sln -c Release -o D:\\CloudBLM_UAT\\EmailService'
   deleteDir()
}

}

 stage('service stop')
{
  node('master'){
    // Run the job in master jenkins
      stage('playbook-checkout')
      {
        // clean the current workspace and checkout the code from Devops repository
          cleanWs() 
          checkout([$class: 'SubversionSCM', additionalCredentials: [], excludedCommitMessages: '', excludedRegions: '', excludedRevprop: '', excludedUsers: '', filterChangelog: false, ignoreDirPropChanges: false, includedRegions: '', locations: [[cancelProcessOnExternalsFail: true, credentialsId: '585fa701-720a-4602-abe6-b977c8773a4c', depthOption: 'infinity', ignoreExternalsOption: true, local: '.', remote: 'https://192.168.1.200/svn/CloudBLM-DevOps/deployment/windows-playbook/UAT-Ansible/EmailService']], quietOperation: true, workspaceUpdater: [$class: 'UpdateUpdater']])
      }
      stage('Start IIS website')
      {
           // Start the IIS service via ansible and delete the working dir in jenkins
       sh 'ansible-playbook EmailService-start.yml'
         deleteDir()
      }
  }
}

	
	
		  currentBuild.result = 'SUCCESS'
    } catch (Exception err) {
        currentBuild.result = 'FAILURE'
    
		   stage('Notify') {
        if(currentBuild.result == 'FAILURE') {
         mail bcc: '', body: "Hi,\n Jenkins have some issues in  ${JOB_NAME} build #${BUILD_NUMBER} \n\n Build URL = ${BUILD_URL} \n\n Job URL = ${JOB_URL}", cc: '', from: 'sysadmin@srinsofttech.com', replyTo: '', subject: "Problem in ${JOB_NAME} build #${BUILD_NUMBER}", to: 'jagadeesan@srinsofttech.com'
        }
    }
    }
}

