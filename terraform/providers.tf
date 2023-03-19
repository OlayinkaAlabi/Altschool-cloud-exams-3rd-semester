terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = ">= 4.0"
    namedotcom = {
      source  = "lexfrei/namedotcom"
      version = "1.2.5"
    }    
  }

  backend "s3" {
    region         = "us-east-1"
    bucket         = "altschool-tf-state"
    key            = "exam/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

provider "namedotcom" {
  username = var.namedotcom_username
  token    = var.namedotcom_token
}

data "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name
  depends_on = [
    aws_eks_cluster.eks-cluster
  ]
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks-cluster.name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority.0.data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks-cluster.name]
    command     = "aws"
  }
}
