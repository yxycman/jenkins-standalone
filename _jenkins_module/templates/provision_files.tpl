# Jenkis has constant issues with mirrors (Operation too slow | Connection timed out), we can try to switch between jenkins.io and jenkins-ci.org

runcmd:
  - [ sudo, amazon-linux-extras, install, java-openjdk11 ]
  - [ sudo, wget, -O, '/etc/yum.repos.d/jenkins.repo', 'http://pkg.jenkins-ci.org/redhat/jenkins.repo' ]
  - [ sudo, rpm, --import, 'https://jenkins-ci.org/redhat/jenkins-ci.org.key' ]
  - [ wget, 'https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip' ]
  - [ unzip, 'terraform_0.12.18_linux_amd64.zip' ]
  - [ chmod, 755, terraform ]
  - [ sudo, mv, terraform, '/usr/bin/' ]
  - [ sudo, yum, install, -y, jenkins, git ]
  - [ sed,  -i, s#JENKINS_ARGS=\"\"#JENKINS_ARGS=\"-Djenkins.install.runSetupWizard=false\"#, /etc/sysconfig/jenkins ]
  - [ wget, 'http://s3.${region}.amazonaws.com/${region}-sserve-jenkins-demo-${random}/_zipped_plugins.zip' ]
  - [ sudo, unzip, '-o', _zipped_plugins.zip, '-d', /var/lib/jenkins/plugins/ ]
  - [ sudo, chown, '-R', 'jenkins:jenkins', /var/lib/jenkins/plugins/ ]
  - [ sudo, service, jenkins, start ]

write_files:
  - path: /var/lib/jenkins/init.groovy.d/00-base.groovy
    permissions: "644"
    content: |
      import jenkins.model.*
      import jenkins.install.*
      import hudson.security.*
      import java.util.concurrent.*

      def hudsonRealm = new HudsonPrivateSecurityRealm(false)
      hudsonRealm.createAccount("admin", "${admin_password}")

      def instance = Jenkins.getInstance()

      //instance.getPluginManager().doCheckUpdatesServer()
      //plugins_to_install = [ 'workflow-aggregator', 'git', 'ansiColor' ]
      //plugins_to_install.each { 
      //  instance.updateCenter.getPlugin(it).deploy().get(3, TimeUnit.MINUTES)
      //}

  - path: /var/lib/jenkins/init.groovy.d/22-job.groovy
    permissions: "644"
    content: |
      import jenkins.model.*
      import jenkins.install.*
      import hudson.tasks.Shell
      import hudson.plugins.git.*
      import hudson.model.*
      import org.jenkinsci.plugins.workflow.job.WorkflowJob
      import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition

      def instance = Jenkins.getInstance()

      userConfig     = [new UserRemoteConfig("${stack_url}", null, null, null)]
      branchConfig   = [new BranchSpec("*/master")]
      scm            = new GitSCM(userConfig, branchConfig, false, [], null, null, null)
      bucketParam    = new StringParameterDefinition("STATE_BUCKET", "${state_bucket}")
      regionParam    = new StringParameterDefinition("STATE_BUCKET_REGION", "${region}")

      if (!instance.getJob('terraform-deploy')) {
        job            = instance.createProject(WorkflowJob, 'terraform-deploy')
        flowDefinition = new CpsScmFlowDefinition(scm, 'managed_stack/Jenkinsfile')
        flowDefinition.setLightweight(true)
        job.setDefinition(flowDefinition)
        job.addProperty(new ParametersDefinitionProperty([bucketParam, regionParam]))
        job.save()
      }
      
      if (!instance.installState.isSetupComplete()) {
        instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
        instance.restart()
      }

  - path: /var/lib/jenkins/init.groovy.d/99-reboot-if-not-setup.groovy
    permissions: "644"
    content: |
      import jenkins.model.*

      def instance = Jenkins.getInstance()
      
      if (!instance.installState.isSetupComplete()) {
        instance.restart()
      }