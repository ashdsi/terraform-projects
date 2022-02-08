# ========================================================================================================================== #

#--------------------------------------------------------------#
#Render the template with a substituted value for EKS Cluster Name
# resource "local_file" "parent_kubeconfig_file" {
#     content   = data.template_file.kubeconfig.rendered
#     filename  = "${path.module}/eks-cluster-config.yaml"
# } 
#--------------------------------------------------------------#

#--------------------------------------------------------------#
/* Update the "coredns" discovery service to work against
the EKS Foundation Cluster */
module "eks-coredns-setup" {
    #count                           = var.ConfigureEKSFargateModel == "true" ? 1 : 0
    
    source                          = "../2-sub-modules/a-coredns-stack"

    deploymentPrefix                = local.envPrefixName
    eksClusterCertificateAuthority  = data.aws_eks_cluster.eks_name.certificate_authority[0].data
    eksClusterEndpoint              = data.aws_eks_cluster.eks_name.endpoint
    eksClusterName                  = var.EKSFoundationClusterName
    iamRoleForOIDC                  = var.EKSIamRoleNameForCNI
    #kubeConfigFile                  = local_file.parent_kubeconfig_file.filename
    #pipelineDeployment              = var.DeployFromPipeline
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
/* Append the "Cert-Manager" & "AWS LB Controller" application setup
against the EKS Foundation Cluster */
module "eks-alb-controller-setup" {
    source                          = "../2-sub-modules/b-alb-controller-stack"

    /* providers = {
      kubernetes  = kubernetes.eks-foundation-cluster
      helm        = helm.public-chart-museum-eks-foundation-cluster
    } */

    deploymentPrefix                = local.envPrefixName
    deployedRegion                  = var.region
    eksClusterName                  = var.EKSFoundationClusterName
    resourceTags                    = local.commonTags
}
#--------------------------------------------------------------#


#--------------------------------------------------------------#
/* Create the Metrics-server setup against the EKS Foundation Cluster
to plug in the auto-scaling capabilities */
# module "eks-metrics-server-setup" {
#     count                           = var.ConfigureEKSFargateModel == "true" ? 1 : 0
    
#     source                          = "../2-sub-modules/c-metrics-server-stack"
#     providers = {
#       kubernetes = kubernetes.eks-foundation-cluster
#     }

#     deploymentPrefix                = local.envPrefixName
#     deployedRegion                  = var.region
#     eksClusterName                  = var.EKSFoundationClusterName
#     metricsServerNamespace          = var.MetricsServerCustomNamespace
#     metricsServerRepoName           = var.MetricsServerECRRepoName
#     metricsServerImageTag           = var.MetricsServerECRImageTagName
#     resourceTags                    = local.commonTags
# }
#--------------------------------------------------------------#

# ========================================================================================================================== #
