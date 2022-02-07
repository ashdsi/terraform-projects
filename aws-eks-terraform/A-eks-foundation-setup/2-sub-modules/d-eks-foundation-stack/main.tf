# ========================================================================================================================== #

#--------------------------------------------------------------#
# Create a EKS Foundation Cluster & securely host it within VPC #
resource "aws_eks_cluster" "eks_foundation_cluster" {
  name     = join ("-", [var.deploymentPrefix,var.deployedRegion,"l1"])
  role_arn = var.serviceRoleArn

  version = var.k8sversion

  vpc_config {
    endpoint_private_access = "false"
    endpoint_public_access = "true"
    security_group_ids = [ data.aws_security_group.eks_cluster_control_plane_sec_group.id ]
    subnet_ids = [data.aws_subnet.pubsubnet1.id,data.aws_subnet.pubsubnet2.id,data.aws_subnet.prisubnet1.id,data.aws_subnet.prisubnet2.id ]
  }
  
  tags = merge(var.resourceTags,{
    "Product" = "AWS-Compute"
    "Service" = "EKS-Foundation-Cluster"
    }
  )
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create specific ingress rules to ensure communication is established between
# EKS cluster control plane (appended during cluster creation) & 
# the shared nodes (on which workloads would be hosted) of the EKS cluster #
# resource "aws_security_group_rule" "ingress_rule_for_eks_cluster_sec_group_against_shared_node_sec_group" {
#   description               = "Allow unmanaged nodes to communicate with control plane (all ports)"
#   type                      = "ingress"
#   from_port                 = "-1"
#   to_port                   = "-1"
#   protocol                  = "all"
#   security_group_id         = aws_eks_cluster.eks_foundation_cluster.vpc_config[0].cluster_security_group_id
#   source_security_group_id  = data.aws_security_group.eks_cluster_shared_node_sec_group.id
# }

# resource "aws_security_group_rule" "ingress_rule_for_shared_node_sec_group_against_eks_cluster_sec_group" {
#   description               = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
#   type                      = "ingress"
#   from_port                 = "-1"
#   to_port                   = "-1"
#   protocol                  = "all"
#   security_group_id         = data.aws_security_group.eks_cluster_shared_node_sec_group.id
#   source_security_group_id  = aws_eks_cluster.eks_foundation_cluster.vpc_config[0].cluster_security_group_id
# }
# #--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create an IAM Identify Provider (with thumbprint) against the newly
# created EKS cluster, which would be used for OIDC-based authentication #
resource "aws_iam_openid_connect_provider" "for_eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_foundation_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_foundation_cluster.identity[0].oidc[0].issuer

  tags = merge(var.resourceTags,{
    "Product" = "AWS-Identity-Authentication"
    "Service" = "Identity-Provider"
    }
  )
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create an IAM Roles for the Service Account (kube-system/aws-node)
# which would be mapped to the EKS cluster #
resource "aws_iam_role" "oidc_web_role_for_eks_managed_account" {
  name               = "${var.deploymentPrefix}-eks-oidc-managed-iam-role"
  description        = "This is a custom IAM Role with \"OIDC-Web-Identity\" as trusted entity, and will be used exclusively to map to a service account (kube-system/aws-node) within EKS cluster"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.oidc_web_trust_policy_for_eks_managed_account.json

  tags = merge(var.resourceTags,{
    "IAMTagFor" = "OIDC-Web-Identity-Role-For-EKS-Cluster"
    "Product" = "AWS-Identity-Authentication"
    "Service" = "IAM-Role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "attach_aws_managed_cni_policy_for_eks_managed_account" {
  role       = aws_iam_role.oidc_web_role_for_eks_managed_account.id
  policy_arn = data.aws_iam_policy.eks_cni_policy.arn
}
#--------------------------------------------------------------#

# ========================================================================================================================== #
