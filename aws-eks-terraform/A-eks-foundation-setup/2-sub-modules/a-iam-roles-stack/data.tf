# ========================================================================================================================== #

#--------------------------------------------------------------#
# Reference AWS Account #
data "aws_caller_identity" "current" {}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create IAM Trust policy for the Service Role to map to EKS cluster #
data "aws_iam_policy_document" "eks_cluster_service_role_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Retrieve the AWS EKS Cluster policy to be appended to Service Role 
# of the EKS Cluster #
data "aws_iam_policy" "eks_cluster_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Retrieve the AWS EKS VPC Resource Controller policyto be appended to 
# Service Role of the EKS Cluster #
data "aws_iam_policy" "vpc_resource_controller_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create Managed Policy definition for EKS cluster to interact with 
# CloudWatch metrics
data "aws_iam_policy_document" "managed_inline_policy_for_cloudwatch_metrics" {
  statement {
    sid = "InteractWithCloudWatchMetrics"
    actions = [ "cloudwatch:PutMetricData" ]
    resources = [ "*" ]
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create Managed Policy definition for EKS cluster to interact with 
# AWS Elastic LoadBalancer
data "aws_iam_policy_document" "managed_inline_policy_for_elb" {
  statement {
    sid = "InteractWithELBService"
    actions = [ "ec2:DescribeAccountAttributes","ec2:DescribeAddresses","ec2:DescribeInternetGateways" ]
    resources = [ "*" ]
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== FARGATE CLUSTER SPECIFIC INVOCATION ONLY ==========
# Create IAM Trust policy for the Fargate Pod Exec Role to map to EKS cluster #
data "aws_iam_policy_document" "eks_fargate_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== FARGATE CLUSTER SPECIFIC INVOCATION ONLY ==========
# Retrieve the AWS EKS Fargate Pod Exection Policy, which would be 
# appended to the different Fargate profiles mapped to EKS cluster#
data "aws_iam_policy" "eks_fargate_pod_exec_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== MNG CLUSTER SPECIFIC INVOCATION ONLY ==========
# Create IAM Trust policy for the MNG's Node Instance Role to map to EKS cluster #
# data "aws_iam_policy_document" "eks_mng_trust_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== MNG CLUSTER SPECIFIC INVOCATION ONLY ==========
# Retrieve the AWS EKS Worker Node Policy, which would be 
# appended to the Node Instance Role mapped to EKS cluster#
# data "aws_iam_policy" "eks_mng_worker_node_policy" {
#   arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== MNG CLUSTER SPECIFIC INVOCATION ONLY ==========
# Retrieve the AWS EKS Container Registry Policy, which would be 
# appended to the Node Instance Role mapped to EKS cluster#
# data "aws_iam_policy" "eks_mng_container_registry_policy" {
#   arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# ========== MNG CLUSTER SPECIFIC INVOCATION ONLY ==========
# Retrieve the AWS EKS SSM Instance Core Policy, which would be 
# appended to the Node Instance Role mapped to EKS cluster#
# data "aws_iam_policy" "eks_mng_ssm_instance_core_policy" {
#   arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }
#--------------------------------------------------------------#

# ========================================================================================================================== #
