# output "eks_cluster_shared_node_sec_group_id" {
#   description = "Returns the Id of the Security Group which would be used for EKS Cluster's Shared Node communication"
#   value = aws_security_group.eks_cluster_shared_node_sec_group.id
# }

output "eks_cluster_control_plane_sec_group_id" {
  description = "Returns the Id of the Security Group, which would be used as primary mode of communication within EKS Cluster's Control Plane"
  value = aws_security_group.eks_cluster_control_plane_sec_group.id
}

output "vpc_id" {
  description = "Returns the newly created VPC ID, to host the EKS Cluster"
  value = aws_vpc.foundation.id
}
