// create an kubernetes cluster from scratch
//create  aws-ebs instances
//create  aws-ebs volumes
//create  aws-ebs volumes

resource "aws_instance" "instances" {
  depends_on             = ["aws_ami.kubernetes"]
  count                  = var.instance_count
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  iam_instance_profile   = aws_iam_instance_profile.default.name
  ami                    = data.aws_ami.kubernetes.id
  instance_type          = "m5a.xlarge"
  tags = {
    Name = "test-k8s-cluster"
  }
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 10
  }
}

data "aws_ami" "kubernetes" {
  most_recent = true
  owners      = ["137112412989"] # Canonical

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id      = aws_vpc.default.id
}
resource "helm_release" "rancher" {
  depends_on = ["aws_instance.instances"]
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts"
  chart      = "stable/rancher"

}
resource "rke_cluster" "test-cluster" {
  nodes {
    address = aws_instance.instances.0.public_ip
    user    = var.default_user
    role    = ["controlplane", "etcd", "worker"]
    ssh_key = file("~/.ssh/id_rsa")
  }
}