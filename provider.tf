terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    rke = {
      source  = "rancher/rke"
      version = "1.3.0"
    }
  }

  provider "aws" {
    region                 = "us-east-1"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    iam_instance_profile   = aws_iam_instance_profile.default.name
  }
  provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
  }
  provider "rke" {
    log_file = "rke_debug.log"
  }
}