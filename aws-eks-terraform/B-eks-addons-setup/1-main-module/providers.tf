#--------------------------------------------------------------#
# Requested set of providers #
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.4.1"
    }
    
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.7.1"
    }

    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2.1.0"
    }

    null = {
      source = "hashicorp/null"
      version = "~> 3.1.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.13.1"
    }

  }

  # dropped the hard-coded reference to the terraform-back-end config, as it needs to be initialized from the GitLab-IaC pipelines
  #backend "s3" {}

}

#Set the AWS Provider region
provider "aws" {
  region = "us-east-1"          
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Reference EKS Cluster to create connections for the helm provider
# which should install packages like cert-manager, metrics-server &
# AWS-LB controller #
provider "kubernetes" {
  alias                  = "eks-foundation-cluster"

  host                   = data.aws_eks_cluster.eks_name.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_name.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  
#Some cloud providers have short-lived authentication tokens that can expire relatively quickly. 
#To ensure the Kubernetes provider is receiving valid credentials, an exec-based plugin can be used to fetch a new token before initializing the provider. 
#For example, on EKS, the command eks get-token can be used.
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.EKSFoundationClusterName ]
    command     = "aws"
  }
}

provider "helm" {
  alias = "public-chart-museum-eks-foundation-cluster"

  kubernetes {
    config_path             = local_file.parent_kubeconfig_file.filename
    host                    = data.aws_eks_cluster.eks_name.endpoint
    cluster_ca_certificate  = base64decode(data.aws_eks_cluster.eks_name.certificate_authority[0].data)
    token                   = data.aws_eks_cluster_auth.eks_auth.token

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.EKSFoundationClusterName ]
      command     = "aws"
    }
  }
}
#--------------------------------------------------------------#

provider "kubectl" {
  load_config_file       = false
  host                   = data.aws_eks_cluster.eks_name.endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_name.certificate_authority[0].data)
}