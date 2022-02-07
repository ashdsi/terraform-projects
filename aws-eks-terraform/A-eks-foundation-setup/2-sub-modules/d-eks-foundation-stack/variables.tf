# variable "clusterSharedNodeSecGroupId" {
#     description = "Please provide the Id of the Security Group which would be used for EKS Cluster's Shared Node communication"
#     type = string
# }


variable "clusterControlPlaneSecGroupId" {
    description = "Please provide the Id of the Security Group, which would be used as primary mode of communication within EKS Cluster's Control Plane"
    type = string
}

variable "deploymentPrefix" {
    description = "Please choose a custom name which will be prefixed for all the AWS resources"
    type = string
}

variable "deployedRegion" {
    description = "Please choose the region where the EKS Cluster needs to be deployed"
    type = string
}

variable "vpcId" {
    description = "Please provide the newly created VPC ID, to host the EKS Cluster"
    type = string
}

variable "resourceTags" {
    description = "Please add resource tags upon creation"
    type = map
}

variable "serviceRoleArn" {
    description = "Please provide the Amazon Resource Name (ARN) for the Service Role to be associated with EKS Cluster"
    type = string
}

variable "k8sversion" {
    description = "Please provide the Amazon Resource Name (ARN) for the Service Role to be associated with EKS Cluster"
    type = string
}

