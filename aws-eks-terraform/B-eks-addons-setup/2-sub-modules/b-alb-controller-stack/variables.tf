variable "deploymentPrefix" {
    description = "Please choose a custom name which will be prefixed for all the AWS resources"
    type = string
}

variable "eksClusterName" {
    description = "Please specify the name of the EKS Cluster which is deployed in your environment"
    type = string
}

variable "deployedRegion" {
    description = "Please choose the region where the EKS Cluster has been deployed"
    type = string
}

variable "resourceTags" {
    description = "Please add resource tags upon creation"
    type = map
}
