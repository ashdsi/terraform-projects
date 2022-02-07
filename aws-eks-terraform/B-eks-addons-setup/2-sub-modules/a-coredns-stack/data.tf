# ========================================================================================================================== #

#--------------------------------------------------------------#
# Reference IAM Role to map to kube service account (aws-node) #
data "aws_iam_role" "eks_managed_account" {
  name = var.iamRoleForOIDC
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Reference EKS Cluster #
data "aws_eks_cluster" "eks_name" {
  name = var.eksClusterName
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = var.eksClusterName
}

data "template_file" "kubeconfig" {
  template = <<EOF
apiVersion: v1
kind: Config
current-context: terraform
clusters:
- name: ${var.eksClusterName}
  cluster:
    certificate-authority-data: ${data.aws_eks_cluster.eks_name.certificate_authority[0].data}
    server: ${data.aws_eks_cluster.eks_name.endpoint}
contexts:
- name: terraform
  context:
    cluster: ${var.eksClusterName}
    user: terraform
users:
- name: terraform
  user:
    token: ${data.aws_eks_cluster_auth.eks_auth.token}
EOF
}
#--------------------------------------------------------------#

# ========================================================================================================================== #
