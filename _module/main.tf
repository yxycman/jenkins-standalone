provider "aws" {
  region = var.aws_region
}

provider "random" {}

#------------------------------------
# Network configuration
#------------------------------------

resource "aws_vpc" "jenkins" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "jenkins test VPC"
  }
}

resource "aws_internet_gateway" "jenkins" {
  vpc_id = aws_vpc.jenkins.id

  tags = {
    Name = "jenkins IGW"
  }
}

resource "aws_route_table" "jenkins" {
  vpc_id = aws_vpc.jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins.id
  }

  tags = {
    Name = "jenkins"
  }
}

resource "aws_main_route_table_association" "jenkins" {
  vpc_id         = aws_vpc.jenkins.id
  route_table_id = aws_route_table.jenkins.id
}

resource "aws_subnet" "jenkins" {
  vpc_id                  = aws_vpc.jenkins.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins test subnet"
  }
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins"
  vpc_id      = aws_vpc.jenkins.id

  # Outbound everything
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound 22 from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound 8080 from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound self
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}

#------------------------------------
# Instance configuration
#------------------------------------

resource "random_id" "jenkins_uniq" {
  byte_length = 4
}

# We need to have dozens of modules and Jenkins mirrors are not very stable, 
# thus we provide .zip file with needed plugin this way, to minimize `connect timed out` errors during bootstrap
resource "aws_s3_bucket" "jenkins" {
  bucket = "${var.aws_region}-sserve-jenkins-demo-${random_id.jenkins_uniq.dec}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "jenkins_plugins" {
  key    = "_zipped_plugins.zip"
  bucket = aws_s3_bucket.jenkins.id
  source = "_module/_zipped_plugins.zip"
  acl    = "public-read"
}

resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = var.public_key
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon-linux-2-ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.jenkins.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = aws_key_pair.jenkins.key_name
  user_data              = data.template_cloudinit_config.jenkins.rendered

  tags = {
    Name = "oliashuk jenkins instance"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_cloudinit_config" "jenkins" {
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.provision_files.rendered
  }
}

data "template_file" "provision_files" {
  template = file("${path.module}/templates/provision_files.tpl")

  vars = {
    admin_password = var.admin_password
    region         = var.aws_region
    random         = random_id.jenkins_uniq.dec
    stack_url      = var.stack_url
  }
}

data "aws_ami" "amazon-linux-2-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}