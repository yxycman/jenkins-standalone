module "jenkins" {
  source     = "./_jenkins_module"
  aws_region = "eu-north-1"
  stack_url  = "https://github.com/yxycman/jenkins-standalone.git"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfnDPEBwRr8V6dBbAx5EM4RwpQYZ7WZS1aEzt/MoWF2LmSCX6bfAnKPG4/SkgPkY+TvWu5WQr+Pn2tgRcB4r51s8Ub+XDveyvoDDKtdek3Q9YtX2NQpwxliuzLLZVgZ3+YSHbHLhFH9LAQ+2U2BAtFkgwP1tBVUzPEqkFCVcSX78kQI2Yu6LivNMgZ4uCdKV1jQ8dDnABLlhK8frrRsSSq+YMe8x5f0eFwdA0bqIIymDOOKt5Hsjpj98ZSsXiXBtqJPsOy/D2g1Kyxp72QP6+l7vifNpfcU0Vv+1EACjKPFcCw7k8yfsDUsuKQiEDkJTvfQUJuAQSNzWDdaTwwV73b8eLAkXjzpsww5lXr0dgm2t+qUrB66XWwHF1FNnW+evX/kuSrdGxeAoaNKhQ6X63QntDvlKBRV+iXJf8rF3sQ7M4kcMYkVwbTL3AgZBULILEoF85a+K0DQiPwIH6vu2jX5A5np0W24yFtguNSMrn1JuoUJhqkpSxnJkbwzCPO2aDpYMOpm9lxNoo1ooOdkpNiO7VJ3dwBLAThgNAO0HJv/V843/S6GSN4g/QWpcdxxaIJnIQRjqY0MyZvdZ8xzDKNo2IB9I9wXPKRuU475PG4OEBN6LiqnTTDkK3wHApn/aKJwMWmmPEBUBk0NTCaUTCZSGzroQLy4RJEIea2mfFJsw=="
}

output "instance_ip" {
  value = module.jenkins.instance_ip
}
