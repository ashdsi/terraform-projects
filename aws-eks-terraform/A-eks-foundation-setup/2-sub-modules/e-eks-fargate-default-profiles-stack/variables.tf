variable "deploymentPrefix" {
    description = "Please choose a custom name which will be prefixed for all the AWS resources"
    type = string
}

variable "eksClusterName" {
    description = "Please provide the name of the EKS Fargate cluster created earlier to map the Fargate profiles"
    type = any
}

variable "fargatePodExecRoleArn" {
    description = "Please provide the Amazon Resource Name (ARN) for the Fargate Pod Exec Role to be associated with EKS Cluster's Fargate profile"
    type = any
}

variable "vpcId" {
    description = "Please provide the newly created VPC ID, to host the EKS Cluster"
    type = string
}

variable "resourceTags" {
    description = "Please add resource tags upon creation"
    type = map
}
