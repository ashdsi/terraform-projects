# ========================================================================================================================== #

#--------------------------------------------------------------#
# Reference EKS Cluster #
data "aws_eks_cluster" "eks_name" {
  name = var.EKSFoundationClusterName
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = var.EKSFoundationClusterName
}

data "template_file" "kubeconfig" {
  template = <<EOF
apiVersion: v1
kind: Config
current-context: terraform
clusters:
- name: ${var.EKSFoundationClusterName}
  cluster:
    certificate-authority-data: ${data.aws_eks_cluster.eks_name.certificate_authority[0].data}
    server: ${data.aws_eks_cluster.eks_name.endpoint}
contexts:
- name: terraform
  context:
    cluster: ${var.EKSFoundationClusterName}
    user: terraform
users:
- name: terraform
  user:
    token: ${data.aws_eks_cluster_auth.eks_auth.token}
EOF
}
#--------------------------------------------------------------#

# ========================================================================================================================== #
