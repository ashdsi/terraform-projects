#--------------------------------------------------------------#
# Requested set of providers #
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.2"
    }
    
    # kubernetes = {
    #   source = "hashicorp/kubernetes"
    #   version = "~> 2.3.0"
    # }

    # template = {
    #   source = "hashicorp/template"
    #   version = "~> 2.2"
    # }

    local = {
      source = "hashicorp/local"
      version = "~> 2.1.0"
    }

    # null = {
    #   source = "hashicorp/null"
    #   version = "~> 2.1"
    # }
    
  }

  # dropped the hard-coded reference to the terraform-back-end config, as it needs to be initialized from the GitLab-IaC pipelines
  #backend "s3" {}

}



provider "aws" {
  region = "us-east-1"          #Set the AWS Provider region
}


#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Reference EKS Cluster as it would be used exclusively during
# # the MNG module deployment #
# provider "kubernetes" {
#   alias                  = "eks-foundation-cluster"

#   host                   = module.eks-foundation-cluster.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks-foundation-cluster.eks_cluster_ca)
#   token                  = data.aws_eks_cluster_auth.eks_auth.token
  
#   exec {
#     api_version = "client.authentication.k8s.io/v1alpha1"
#     args        = ["eks", "get-token", "--cluster-name", module.eks-foundation-cluster.eks_cluster_name ]
#     command     = "aws"
#   }
# }
#--------------------------------------------------------------#
