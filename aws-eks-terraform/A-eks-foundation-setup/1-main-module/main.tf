# ========================================================================================================================== #

#--------------------------------------------------------------#
/* Create IAM Roles necessary for the EKS cluster */
module "iam-roles" {
    source              = "../2-sub-modules/a-iam-roles-stack"

    deploymentPrefix    = local.envPrefixName
    resourceTags        = local.commonTags
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
/* Create a timer to delay the deletion of the IAM Roles, Policies, Instance profiles during resource deletion */
resource "time_sleep" "wait_for_60_seconds" {
  depends_on = [ module.iam-roles ]

  destroy_duration = "60s"
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
/* Create VPC module to host the EKS cluster */
module "network" {
    depends_on          = [ time_sleep.wait_for_60_seconds ]
    source              = "../2-sub-modules/b-network-stack"

    deploymentPrefix    = local.envPrefixName
    deployedRegion      = var.region
    resourceTags        = local.commonTags
    vpcCidrRange        = var.VPCCidrBlock
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
/* Create ECR repositories for various applications */
module "ecr-repo" {
    source              = "../2-sub-modules/c-compute-ecr-stack"

    deploymentPrefix    = local.envPrefixName
    resourceTags        = local.commonTags
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
/* Create the bare-bone EKS foundation cluster with appropriate IAM Roles
& security groups */
module "eks-foundation-cluster" {
    depends_on                      = [ time_sleep.wait_for_60_seconds, module.iam-roles, module.network ]
    source                          = "../2-sub-modules/d-eks-foundation-stack"

    #clusterSharedNodeSecGroupId     = module.network.eks_cluster_shared_node_sec_group_id
    clusterControlPlaneSecGroupId   = module.network.eks_cluster_control_plane_sec_group_id
    deploymentPrefix                = local.envPrefixName
    deployedRegion                  = var.region
    resourceTags                    = local.commonTags
    serviceRoleArn                  = module.iam-roles.service_role_arn_cluster
    vpcId                           = module.network.vpc_id
    k8sversion                      = var.Version

}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
/* Create the fargate profiles (default for cluster) mapped against the pre-created
EKS Cluster */
module "eks-fargate-default-profiles" {
    #count                           = var.DeployEKSFargateModel == "true" ? 1 : 0

    depends_on                      = [ module.eks-foundation-cluster ]
    source                          = "../2-sub-modules/e-eks-fargate-default-profiles-stack"

    deploymentPrefix                = local.envPrefixName
    eksClusterName                  = module.eks-foundation-cluster.eks_cluster_name
    fargatePodExecRoleArn           = module.iam-roles.fargate_pod_exec_role_arn
    resourceTags                    = local.commonTags
    vpcId                           = module.network.vpc_id
}
#--------------------------------------------------------------#

# #--------------------------------------------------------------#
# /* Create the fargate profiles (for various tenants) mapped against the pre-created
# EKS Cluster */
# module "eks-fargate-tenant-profiles" {
#     count                           = var.DeployEKSFargateModel == "true" ? 1 : 0

#     depends_on                      = [ module.eks-fargate-default-profiles ]
#     source                          = "../2-sub-modules/f-eks-fargate-tenant-profiles-stack"

#     deploymentPrefix                = local.envPrefixName
#     eksClusterName                  = module.eks-foundation-cluster.eks_cluster_name
#     fargatePodExecRoleArn           = module.iam-roles.fargate_pod_exec_role_arn
#     resourceTags                    = local.commonTags
#     vpcId                           = module.network.vpc_id
# }
# #--------------------------------------------------------------#

# #--------------------------------------------------------------#
# /* Create the Launch Template, which would be the back-bone for the 
# EC2 instances created by the Managed Node Group 9MNG) for the EKS cluster */
# module "eks-mng-launch-template-setup" {
#     count                           = var.DeployEKSMNGModel == "true" ? 1 : 0

#     depends_on                      = [ module.eks-foundation-cluster ]
#     source                          = "../2-sub-modules/g-eks-mng-launch-template-stack"

#     deploymentPrefix                = local.envPrefixName
#     eksClusterCertificateAuthority  = module.eks-foundation-cluster.eks_cluster_ca
#     eksClusterEndpoint              = module.eks-foundation-cluster.eks_cluster_endpoint
#     eksClusterName                  = module.eks-foundation-cluster.eks_cluster_name
#     eksClusterSecGroupId            = module.eks-foundation-cluster.eks_cluster_security_group_id
#     eksIAMRoleArnForOIDC            = module.eks-foundation-cluster.eks_managed_iam_role_arn
#     eksMNGNodeInstanceRoleArn       = module.iam-roles.mng_node_instance_role_arn
#     pipelineDeployment              = var.DeployFromPipeline
#     resourceTags                    = local.commonTags
#     vpcId                           = module.network.vpc_id
# }
# #--------------------------------------------------------------#

# # ========================================================================================================================== #
