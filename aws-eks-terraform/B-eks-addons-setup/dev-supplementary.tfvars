# these parameters (below) captures the relevant info pertaining to an already available EKS cluster name (ver: 1.19 preferable)
EKSFoundationClusterName                = "iac-dev-us-east-1-l1"
EKSIamRoleNameForCNI                    = "iac-dev-eks-oidc-managed-iam-role"

# these param's variable values (below) are imprinted on all services created as part of Terraform deployement
customer_engagement_id                  = "awsps"
region                                  = "us-east-1"
CreatedBy                               = "Terraform"
#CostCenter                              = "awsps"
#ConfigureEKSFargateModel                = "false"
Environment                             = "dev"
#MetricsServerECRRepoName                = "aws-eks-metric-server"
#MetricsServerECRImageTagName            = "v0.5.0"
Owner                                   = "test@xyz.com"
Project                                 = "iac"
TechnicalOwner                          = "John"
Version                                 = "1.21"
