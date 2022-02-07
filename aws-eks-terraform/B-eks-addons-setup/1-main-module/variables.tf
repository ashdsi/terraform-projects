variable "Project" {
    description = "Please provide the Project Name which would be prefixed uniformly for all resources created as per IaC automation"
    type = string
}

variable "Environment" {
    description = "Please provide the Environment to which the resources would be created"
    type = string
}

locals {
    envPrefixName = "${var.Project}-${var.Environment}"
 
}

locals {

   commonTags = {
    aml-modernized-app  =   var.customer_engagement_id
    ClusterName         =   join ("-", [local.envPrefixName,var.region,"l1"])
    #CostCenter          =   var.CostCenter
    CreatedBy	        =	var.CreatedBy
    Environment	        =	var.Environment
    Owner	            =	var.Owner
    Project	            =	var.Project
    TechnicalOwner      =   var.TechnicalOwner
    Version             =   var.Version
    }
}

variable "customer_engagement_id" {
    description = "please append the bcg's engagement id inline to the AWS Audit Sheet which would be helpful for Billing/Cost tracking & other recommendataions"
    type = string
}

variable "region" {
    description = "Please choose the region where the EKS Cluster has been deployed"
    type = string
}

# variable "ConfigureEKSFargateModel" {
#     description = "Please provide a boolean toggle to setup EKS Fargate model of cluster deployment"
#     type = string
# }

/* variable "ConfigureEKSMNGModel" {
    description = "Please provide a boolean toggle to setup EKS Managed Node Group (MNG model of cluster deployment"
    type = string
} */

# variable "CostCenter" {
#     description = "Please provide the project team's Cost center reference id that would be appended to all resources"
#     type = string
# }

variable "CreatedBy" {
    description = "Please provide the automation mode/tool used for creating the resources"
    type = string
}

# variable "DeployFromPipeline" {
#     description = "Please provide the option if this module needs to be deployed as part of Azure Pipeline or it needs to be deployed locally"
#     type = string
# }

variable "EKSFoundationClusterName" {
    description = "Please specify the name of the EKS Cluster which is deployed in your environment"
    type = string
}

variable "EKSIamRoleNameForCNI" {
    description = "Please provide the friendly name for the IAM role to be used for Pod's CNI connectivity"
    type = string
}

# variable "EKSNameSpaceforOrgBuilderApps" {
#     description = "Please choose a custom name which would be used to create the Kubernetes namespace to host the API's of the OrgBuilder Application"
#     type = string
#     default = "bcg-orgbuilder"
# }

# variable "MetricsServerCustomNamespace" {
#     description = "Please provide a namespace where the Metrics Server package can be installed within EKS cluster"
#     type = string
#     default = "kube-system"
# }

# variable "MetricsServerECRRepoName" {
#     description = "Please provide the ECR Repository Name which houses the Metrics Server application package"
#     type = string
# }

# variable "MetricsServerECRImageTagName" {
#     description = "Please provide the Image Tag Name for the Metrics Server application hosted within ECR Repository"
#     type = string
# }

variable "Owner" {
    description = "Please provide the service account's email address thats in charge of creating resources"
    type = string
}

variable "TechnicalOwner" {
    description = "Please provide the Project Owner's Team/Name who's in charge of billing for the created resources"
    type = string
}

variable "Version" {
    description = "Please provide the Version number that would be appended to all the created resources"
    type = string
}
