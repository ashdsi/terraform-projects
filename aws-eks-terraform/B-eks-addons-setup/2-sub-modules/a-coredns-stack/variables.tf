variable "deploymentPrefix" {
    description = "Please choose a custom name which will be prefixed for all the AWS resources"
    type = string
}

variable "eksClusterName" {
    description = "Please provide the name of the EKS Fargate cluster created earlier to map the Fargate profiles"
    type = string
}

variable "eksClusterCertificateAuthority" {
    description = "Please provide the certificate authority of the EKS Cluster"
    type = string
}

variable "eksClusterEndpoint" {
    description = "Please provide the endpoint of the EKS API Server"
    type = string
}

variable "iamRoleForOIDC" {
    description = "Please provide the friendly name for the IAM role to be used for Pod's CNI connectivity"
    type = string
}

/* variable "kubeConfigFile" {
    description = "Please provide the auto-generated kubernetes configuration file to authenticate to EKS cluster"
    type = any
} */

# variable "pipelineDeployment" {
#     description = "Please provide the option if this module needs to be deployed as part of Azure Pipeline or it needs to be deployed locally"
#     type = string
# }
