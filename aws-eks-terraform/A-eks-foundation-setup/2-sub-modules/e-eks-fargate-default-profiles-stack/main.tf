# ========================================================================================================================== #

#--------------------------------------------------------------#
# Create a EKS Fargate Profile for "kube-system" & "default" namespaces #
resource "aws_eks_fargate_profile" "foundation_profile" {
  cluster_name           = var.eksClusterName
  fargate_profile_name   = "fp-foundation"
  pod_execution_role_arn = var.fargatePodExecRoleArn
  subnet_ids             = [data.aws_subnet.prisubnet1.id,data.aws_subnet.prisubnet2.id]

  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system"
  }
  
  tags = merge(var.resourceTags,{
    "kubernetes.io/cluster/${var.eksClusterName}" = "shared"
    "Product" = "AWS-Compute"
    "Service" = "EKS-Fargate-Profile"
    }
  )

}
#--------------------------------------------------------------#

# Create a EKS Fargate Profile for "kube-system" & "default" namespaces #
resource "aws_eks_fargate_profile" "coredns" {
  cluster_name           = var.eksClusterName
  fargate_profile_name   = "fp-coredns"
  pod_execution_role_arn = var.fargatePodExecRoleArn
  subnet_ids             = [data.aws_subnet.prisubnet1.id,data.aws_subnet.prisubnet2.id]

  selector {
    labels = {
      "k8s-app" = "kube-dns"
    }
    namespace = "kube-system"
  }
  
  tags = merge(var.resourceTags,{
    "kubernetes.io/cluster/${var.eksClusterName}" = "shared"
    "Product" = "AWS-Compute"
    "Service" = "EKS-Fargate-Profile"
    }
  )

}
#--------------------------------------------------------------#

# Create a EKS Fargate Profile for "game-2048" namespace to deploy sample application #
resource "aws_eks_fargate_profile" "sample-app" {
  cluster_name           = var.eksClusterName
  fargate_profile_name   = "fp-sample-app"
  pod_execution_role_arn = var.fargatePodExecRoleArn
  subnet_ids             = [data.aws_subnet.prisubnet1.id,data.aws_subnet.prisubnet2.id]

  selector {
    namespace = "game-2048"
  }
  
  tags = merge(var.resourceTags,{
    "kubernetes.io/cluster/${var.eksClusterName}" = "shared"
    "Product" = "AWS-Compute"
    "Service" = "EKS-Fargate-Profile"
    }
  )

}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create a EKS Fargate Profile for "cert-manager namespace #
# resource "aws_eks_fargate_profile" "cert_manager_profile" {
#   cluster_name           = var.eksClusterName
#   fargate_profile_name   = "fp-cert-manager"
#   pod_execution_role_arn = var.fargatePodExecRoleArn
#   subnet_ids             = [data.aws_subnet.prisubnet1.id,data.aws_subnet.prisubnet2.id]

#   # add the "cert-manager" option for managing K8s's certification management service
#   selector {
#     labels = {
#       "app.kubernetes.io/instance" = "cert-manager"
#     }
#     namespace = "cert-manager"
#   }

#   tags = merge(var.resourceTags,{
#     "kubernetes.io/cluster/${var.eksClusterName}" = "shared"
#     "Product" = "AWS-Compute"
#     "Service" = "EKS-Fargate-Profile"
#     }
#   )

# }
# #--------------------------------------------------------------#

# #--------------------------------------------------------------#
# # Create a EKS Fargate Profile for "kube-system" namespaces in order
# # to deploy AWS LB Controller on it #
# resource "aws_eks_fargate_profile" "alb_controller_profile" {
#   cluster_name           = var.eksClusterName
#   fargate_profile_name   = "fp-alb-controller"
#   pod_execution_role_arn = var.fargatePodExecRoleArn
#   subnet_ids             = [data.aws_subnet.prisubnet1.id,data.aws_subnet.prisubnet2.id]

#   selector {
#     labels = {
#       "app.kubernetes.io/instance" = "aws-load-balancer-controller"
#     }
#     namespace = "kube-system"
#   }

#   tags = merge(var.resourceTags,{
#     "kubernetes.io/cluster/${var.eksClusterName}" = "shared"
#     "Product" = "AWS-Compute"
#     "Service" = "EKS-Fargate-Profile"
#     }
#   )

# }
# #--------------------------------------------------------------#

# #--------------------------------------------------------------#
# # Create a EKS Fargate Profile for "kube-system" namespaces in order
# # to deploy Metrics Server on it #
# resource "aws_eks_fargate_profile" "metrics_server_profile" {
#   cluster_name           = var.eksClusterName
#   fargate_profile_name   = "fp-metrics-server"
#   pod_execution_role_arn = var.fargatePodExecRoleArn
#   subnet_ids             = [data.aws_subnet.prisubnet1.id,data.aws_subnet.prisubnet2.id]

#   selector {
#     labels = {
#       "k8s-app" = "metrics-server"
#     }
#     namespace = "kube-system"
#   }

#   tags = merge(var.resourceTags,{
#     "kubernetes.io/cluster/${var.eksClusterName}" = "shared"
#     "Product" = "AWS-Compute"
#     "Service" = "EKS-Fargate-Profile"
#     }
#   )

# }
#--------------------------------------------------------------#

# ========================================================================================================================== #
