output "eks_cluster_name" {
  description = "Returns the name of the EKS Foundation cluster created in this stage"
  value = aws_eks_cluster.eks_foundation_cluster.name
  depends_on = [ aws_eks_cluster.eks_foundation_cluster ]
}

output "eks_cluster_endpoint" {
  description = "Returns the endpoint of the EKS API Server"
  value = aws_eks_cluster.eks_foundation_cluster.endpoint
  depends_on = [ aws_eks_cluster.eks_foundation_cluster ]
}

output "eks_cluster_ca" {
  description = "Returns the certificate authority of the EKS Cluster"
  value = aws_eks_cluster.eks_foundation_cluster.certificate_authority[0].data
  depends_on = [ aws_eks_cluster.eks_foundation_cluster ]
}

output "eks_managed_iam_role_arn" {
  description = "Returns the Amazon Resource Name (ARN) of the EKS Managed IAM Role to be mapped as part of OIDC authentication to the EKS cluster"
  value = aws_iam_role.oidc_web_role_for_eks_managed_account.arn
}

output "eks_oidc_url" {
  description = "Returns the Issuer URL for the OpenID Connect identity provider associated with the EKS Foundation cluster"
  value = aws_eks_cluster.eks_foundation_cluster.identity[0].oidc[0].issuer
  depends_on = [ aws_eks_cluster.eks_foundation_cluster ]
}

output "eks_cluster_security_group_id" {
  description = "Returns the  Cluster security group that was created by Amazon EKS for the cluster. MNG's use this security group for control-plane-to-data-plane communication"
  value = aws_eks_cluster.eks_foundation_cluster.vpc_config[0].cluster_security_group_id
  depends_on = [ aws_eks_cluster.eks_foundation_cluster ]
}
