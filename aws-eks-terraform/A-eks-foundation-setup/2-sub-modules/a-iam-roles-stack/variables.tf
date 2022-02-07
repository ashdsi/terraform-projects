variable "deploymentPrefix" {
    description = "Please choose a custom name which will be prefixed for all the AWS resources"
    type = string
}

variable "resourceTags" {
    description = "please add resource tags upon creation"
    type = map
}
