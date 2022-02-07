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
    description = "please append the company engagement id inline to the AWS Audit Sheet which would be helpful for Billing/Cost tracking & other recommendataions"
    type = string
}

variable "region" {
    description = "Please choose the region where the EKS Cluster needs to be deployed"
    type = string
}

# variable "CostCenter" {
#     description = "Please provide the project team's Cost center reference id that would be appended to all resources"
#     type = string
# }

variable "CreatedBy" {
    description = "Please provide the automation mode/tool used for creating the resources"
    type = string
}

# variable "DeployEKSFargateModel" {
#     description = "Please provide a boolean toggle to setup EKS Fargate model of cluster deployment"
#     type = string
# }

# variable "DeployEKSMNGModel" {
#     description = "Please provide a boolean toggle to setup EKS Managed Node Group (MNG model of cluster deployment"
#     type = string
# }

# variable "DeployFromPipeline" {
#     description = "Please provide the option if this module needs to be deployed as part of Azure Pipeline or it needs to be deployed locally"
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
    description = "Please provide the Kubernetes Version number that would be used to create the EKS cluster"
    type = string
}

variable "VPCCidrBlock" {
    description = "Please provide the CIDR block for the custom VPC to be created"
    type = string
}

