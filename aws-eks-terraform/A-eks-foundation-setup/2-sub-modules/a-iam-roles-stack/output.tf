output "service_role_arn_cluster" {
  description = "Returns the IAM Service Role ARN for the EKS Cluster setup"
  value = aws_iam_role.eks_cluster_service_role.arn
}

output "fargate_pod_exec_role_arn" {
  description = "Returns the IAM Role ARN for the Fargate Pod Exec role to be mapped to Fargate profiles within EKS Cluster setup"
  value = aws_iam_role.eks_cluster_fargate_pod_exec_role.arn
  depends_on = [ aws_iam_role.eks_cluster_fargate_pod_exec_role  ]
}

# output "mng_node_instance_role_arn" {
#   description = "Returns the IAM Role ARN for the Node Instance Role to be mapped to Managed Node Group (MNG) within EKS Cluster setup"
#   value = aws_iam_role.eks_cluster_mng_node_instance_role.arn
#   depends_on = [ aws_iam_role.eks_cluster_mng_node_instance_role  ]
# }
