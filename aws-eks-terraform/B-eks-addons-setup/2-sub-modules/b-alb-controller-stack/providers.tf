#Added provider configuration again since this error is recieved otherwise 

/*PS D:\gitRepos\GitHub\terraform-projects\aws-eks-terraform\B-eks-addons-setup\1-main-module> terraform apply --auto-approve --var-file=../dev-supplementary.tfvars
╷
│ Error: Provider configuration not present
│
│ To work with module.eks-alb-controller-setup.kubernetes_service_account.aws_lb_controller_sa its original provider configuration at
│ module.eks-alb-controller-setup.provider["registry.terraform.io/hashicorp/kubernetes"].eks-foundation-cluster is required, but it has been removed. 
│ This occurs when a provider configuration is removed while objects created by that provider still exist in the state. Re-add the provider
│ configuration to destroy module.eks-alb-controller-setup.kubernetes_service_account.aws_lb_controller_sa, after which you can remove the provider   
│ configuration again.
╵
╷
│ Error: Provider configuration not present
│
│ To work with module.eks-alb-controller-setup.helm_release.aws_alb_controller its original provider configuration at
│ module.eks-alb-controller-setup.provider["registry.terraform.io/hashicorp/helm"].public-chart-museum-eks-foundation-cluster is required, but it has 
│ been removed. This occurs when a provider configuration is removed while objects created by that provider still exist in the state. Re-add the      
│ provider configuration to destroy module.eks-alb-controller-setup.helm_release.aws_alb_controller, after which you can remove the provider
│ configuration again.

*/


#--------------------------------------------------------------#
# Reference "kubernetes provider" #
terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.13.1"
    }
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Reference EKS Cluster to create connections for the helm provider
# which should install packages like cert-manager, metrics-server &
# AWS-LB controller #
provider "kubernetes" {
  alias                  = "eks-foundation-cluster"

  #config_path            = local_file.parent_kubeconfig_file.filename
  host                   = data.aws_eks_cluster.eks_name.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_name.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.eksClusterName ]
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
      args        = ["eks", "get-token", "--cluster-name", var.eksClusterName ]
      command     = "aws"
    }
  }
}

# Same parameters as kubernetes provider
provider "kubectl" {
  load_config_file       = false
  host                   = data.aws_eks_cluster.eks_name.endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_name.certificate_authority[0].data)
}

#--------------------------------------------------------------#
