# ========================================================================================================================== #

#--------------------------------------------------------------#
# Retrieve the VPC related info #
data "aws_vpc" "foundation" {
  id = var.vpcId
}

data "aws_subnet" "prisubnet1" {
  vpc_id = data.aws_vpc.foundation.id
  filter {
    name   = "tag:SubnetType"
    values = ["Private-Subnet-1"]
  }
}

data "aws_subnet" "prisubnet2" {
  vpc_id = data.aws_vpc.foundation.id
  filter {
    name   = "tag:SubnetType"
    values = ["Private-Subnet-2"]
  }
}
#--------------------------------------------------------------#

# ========================================================================================================================== #
