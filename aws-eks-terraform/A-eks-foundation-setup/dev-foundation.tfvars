# please choose the relevant CIDR range for your VPC; also note that the subnet's CIDR 
# range would be sliced out of the VPC CIDR block
# valid values include: XXX.XXX.0.0/XX range only; i.e. 10.1.0.0/16, 172.32.0.0/18, 192.236.0.0/21
VPCCidrBlock                            = "10.2.0.0/16"

# these param's variable values (below) are imprinted on all services created as part of Terraform deployment
customer_engagement_id                  = "awsps"
region                                  = "us-east-1"
CreatedBy                               = "Terraform"
#CostCenter                              = "awsps"
#DeployEKSFargateModel                   = "false"
#DeployEKSMNGModel                       = "false"
Environment                             = "dev"
Owner                                   = "test@xyz.com"
Project                                 = "iac"
TechnicalOwner                          = "John"
Version                                 = "1.21"
