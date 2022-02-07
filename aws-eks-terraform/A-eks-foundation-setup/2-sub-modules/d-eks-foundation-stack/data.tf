# ========================================================================================================================== #

#--------------------------------------------------------------#
# Retrieve the VPC related info #
data "aws_vpc" "foundation" {
  id = var.vpcId
}

data "aws_subnet" "pubsubnet1" {
  vpc_id = data.aws_vpc.foundation.id
  filter {
    name   = "tag:SubnetType"
    values = ["Public-Subnet-1"]
  }
}

data "aws_subnet" "pubsubnet2" {
  vpc_id = data.aws_vpc.foundation.id
  filter {
    name   = "tag:SubnetType"
    values = ["Public-Subnet-2"]
  }
}

data "aws_subnet" "prisubnet1" {
  vpc_id = data.aws_vpc.foundation.id
  filter {
    name   = "tag:SubnetType"
    values = ["Private-Subnet-1"]
  }
}

data "aws_subnet" "prisubnet2" {
  vpc_id = data.aws_vpc.foundation.id
  filter {
    name   = "tag:SubnetType"
    values = ["Private-Subnet-2"]
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Retrieve the Security Group related info, especially the 
# Cluster's Shared Node Security Group id & Control Plane
# Security Group id #
# data "aws_security_group" "eks_cluster_shared_node_sec_group" {
#   vpc_id = data.aws_vpc.foundation.id
#   id = var.clusterSharedNodeSecGroupId
# }

data "aws_security_group" "eks_cluster_control_plane_sec_group" {
  vpc_id = data.aws_vpc.foundation.id
  id = var.clusterControlPlaneSecGroupId
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create an IAM Identity Provider (with thumbprint) against the newly
# created EKS cluster, which would be used for OIDC-based authentication #
data "tls_certificate" "eks_foundation_cluster" {
  url = aws_eks_cluster.eks_foundation_cluster.identity[0].oidc[0].issuer
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create an IAM Role for the Service Account (kube-system/aws-node)
# which would be mapped to the EKS cluster #
data "aws_iam_policy_document" "oidc_web_trust_policy_for_eks_managed_account" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace("${aws_eks_cluster.eks_foundation_cluster.identity[0].oidc[0].issuer}", "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-node"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace("${aws_eks_cluster.eks_foundation_cluster.identity[0].oidc[0].issuer}", "https://", "")}:aud"
      values = ["sts.amazonaws.com"]
    }
    
    principals {
      type        = "Federated"
      identifiers = [ aws_iam_openid_connect_provider.for_eks_cluster.arn ]
    }
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Retrieve the EKS CNI Policy needed for the IAM role that would be
# mapped to the service-account (kube-system/aws-node)
data "aws_iam_policy" "eks_cni_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
#--------------------------------------------------------------#

# ========================================================================================================================== #
