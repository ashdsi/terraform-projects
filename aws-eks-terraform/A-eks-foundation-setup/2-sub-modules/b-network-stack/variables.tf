variable "deploymentPrefix" {
    description = "Please choose a custom name which will be prefixed for all the AWS resources"
    type = string
}

variable "deployedRegion" {
    description = "Please choose the region where the EKS Cluster needs to be deployed"
    type = string
}

variable "resourceTags" {
    description = "please add resource tags upon creation"
    type = map
}

variable "vpcCidrRange" {
    description = "Please provide the CIDR block for the custom VPC to be created"
    type = string
}
