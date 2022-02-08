# ========================================================================================================================== #

#--------------------------------------------------------------#
# Reference EKS Cluster #
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_name" {
  name = var.eksClusterName
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = var.eksClusterName
}

data "kubectl_path_documents" "docs" {
    pattern = "${path.module}/manifests/*.yaml"
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
# Create ALB IAM Role + Policy Definition to map to EKS cluster #
data "aws_iam_policy_document" "oidc_web_trust_policy_for_alb" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace("${data.aws_eks_cluster.eks_name.identity[0].oidc[0].issuer}", "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace("${data.aws_eks_cluster.eks_name.identity[0].oidc[0].issuer}", "https://", "")}"]
    }
  }
}
#--------------------------------------------------------------#

# ========================================================================================================================== #
