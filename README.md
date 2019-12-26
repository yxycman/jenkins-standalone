## Prerequisites

You need to have:
- terraform v0.12.x installed (tested with v0.12.9).
- SSH private/public keys (public is provided to Jenkins module, so you could have SSH access).
- AWS credentials to any account with enough permissions to create EC2/VPC/IAM/S3 resources in your console.

## Setup

Please open `module_caller.tf` file in a root folder with a text editor and update the following parameters:

> mandatory:
- `public_key`. Public key to your Private SSH key. It will be added to `ec2-user`'s authorozed_keys, so you can log in to an instance.

> nonobligatory:
- `aws_region`. The region, in which we set up our infra
- `admin_password`. If you want to have other, but default, the password for accessing Jenkins via WEB
See the full list of supported variables in the bottom of this document


run from the root folder of this repo: 
- terraform init
- terraform apply

These commands will create EC2 instance and all necessary, for our Demo, resources.
If success, you will receive IP address as an output for `terraform apply` command.

 $ terraform apply
 ...
 Outputs:
 instance_ip = 13.48.23.141

With this IP you can access newly created instance by either SSH port 22 or WEB port 8080

Please wait a few minutes to allow Jenkins to complete setup.
After that, you shall be able to login to Jenkins instance with URL
`http://${IP}:8080`

Login / password is `admin / softserve` (can be configured with terraform's `admin_password` variable)

> Please note:
Jenkins's mirrors are very unstable, and sometimes packets needed for its setup cannot be downloaded. 
Please have a look in these log files on an instance, in case, Jenkins didn't become available within 10 minutes
`/var/log/jenkins/jenkins.log` and `/var/log/cloud-init-output.log`

## Deployments with Jenkins
Few jobs will be deployed as a part of this setup, you can run any of them.
They will apply configurations provided by Jenkinsfiles and stored in related folders

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_password | The password for Jenkins admin user | string | `"softserve"` | no |
| aws\_region | The AWS region in which Service will be created. | string | `"eu-central-1"` | no |
| instance\_type | The type of instance to run | string | `"t3.medium"` | no |
| public\_key | The key to access instance via SSH | string | n/a | yes |
| stack\_url | The URL for TF stack code to deploy with Jenkins | string | `"https://github.com/yxycman/jenkins-standalone.git"` | no |
| vpc\_name | The name of the VPC in which all the resources should be deployed | string | `"jenkins_vpc"` | no |
