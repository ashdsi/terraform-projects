# ========================================================================================================================== #

#--------------------------------------------------------------#
# Create Service Role & append necessary policies for EKS Cluster #
resource "aws_iam_role" "eks_cluster_service_role" {
  name               = join ("-", [var.deploymentPrefix, "eks","cluster","service","role"])
  description        = "This is a custom IAM Service Role with \"EKS\" as trusted entity, and will be used exclusively to map to EKS Cluster's IAM Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_service_role_trust_policy.json

  tags = var.resourceTags
    }


resource "aws_iam_policy" "managed_policy_on_cloudwatch_for_eks_service_role" {
  name = "Managed-Policy-for-CloudWatch-Metrics-interaction-with-EKS-Cluster"
  description = "Managed policy for EKS Service Role to interact with AWS CloudWatch metrics"

  policy = data.aws_iam_policy_document.managed_inline_policy_for_cloudwatch_metrics.json

}

resource "aws_iam_policy" "managed_policy_on_elb_for_eks_service_role" {
  name = "Managed-Policy-for-ELB-interaction-with-EKS-Cluster"
  description = "Managed policy for EKS Service Role to interact with AWS Elastic LoadBalancer"

  policy = data.aws_iam_policy_document.managed_inline_policy_for_elb.json

}

resource "aws_iam_role_policy_attachment" "attach_aws_managed_cloudwatch_policy_to_eks_service_role" {
  role       = aws_iam_role.eks_cluster_service_role.id
  policy_arn = aws_iam_policy.managed_policy_on_cloudwatch_for_eks_service_role.arn
}

resource "aws_iam_role_policy_attachment" "attach_aws_managed_elb_policy_to_eks_service_role" {
  role       = aws_iam_role.eks_cluster_service_role.id
  policy_arn = aws_iam_policy.managed_policy_on_elb_for_eks_service_role.arn
}

resource "aws_iam_role_policy_attachment" "attach_eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_service_role.id
  policy_arn = data.aws_iam_policy.eks_cluster_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_vpc_resource_controller_policy" {
  role       = aws_iam_role.eks_cluster_service_role.id
  policy_arn = data.aws_iam_policy.vpc_resource_controller_policy.arn
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== FARGATE CLUSTER SPECIFIC INVOCATION ONLY ==========
# Create Service Role & append necessary policies for EKS Cluster #
resource "aws_iam_role" "eks_cluster_fargate_pod_exec_role" {
  name               = join ("-", [var.deploymentPrefix, "eks","fargate","pod","exec","role"])
  description        = "This is a custom IAM Service Role with \"EKS-Fargate-Pods\" as trusted entity, and will be used exclusively to map to EKS Cluster's Fargate profiles respectively"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eks_fargate_trust_policy.json
  tags = var.resourceTags
}

# ========== FARGATE CLUSTER SPECIFIC INVOCATION ONLY ==========
resource "aws_iam_role_policy_attachment" "attach_eks_fargate_pod_exec_policy" {
  role       = aws_iam_role.eks_cluster_fargate_pod_exec_role.id
  policy_arn = data.aws_iam_policy.eks_fargate_pod_exec_policy.arn
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== MNG CLUSTER SPECIFIC INVOCATION ONLY ==========
# Create Service Role & append necessary policies for EKS Cluster #
# resource "aws_iam_role" "eks_cluster_mng_node_instance_role" {
#   name               = join ("-", [var.deploymentPrefix, "eks","mng","node","instance","role"])
#   description        = "This is a custom IAM Service Role with \"EC2\" as trusted entity, and will be used exclusively to map to EKS Cluster's Node Instances respectively"
#   path               = "/"
#   assume_role_policy = data.aws_iam_policy_document.eks_mng_trust_policy.json

#   tags = merge(var.resourceTags,{
#     "alpha.eksctl.io/eksctl-version" = "0.50.0"
#     "alpha.eksctl.io/cluster-name" = join ("-", [var.deploymentPrefix,var.deployedRegion,"l1"])
#     "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = join ("-", [var.deploymentPrefix,var.deployedRegion,"l1"])
#     "Product" = "AWS-Identity-Authentication"
#     "Service" = "IAM-Role"
#     }
#   )
# }

# ========== MNG CLUSTER SPECIFIC INVOCATION ONLY ==========
# resource "aws_iam_role_policy_attachment" "attach_eks_mng_worker_node_policy" {
#   role       = aws_iam_role.eks_cluster_mng_node_instance_role.id
#   policy_arn = data.aws_iam_policy.eks_mng_worker_node_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "attach_eks_mng_container_registry_policy" {
#   role       = aws_iam_role.eks_cluster_mng_node_instance_role.id
#   policy_arn = data.aws_iam_policy.eks_mng_container_registry_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "attach_eks_mng_ssm_instance_core_policy" {
#   role       = aws_iam_role.eks_cluster_mng_node_instance_role.id
#   policy_arn = data.aws_iam_policy.eks_mng_ssm_instance_core_policy.arn
# }
#--------------------------------------------------------------#

# ========================================================================================================================== #
