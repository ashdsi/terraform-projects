# ========================================================================================================================== #

#--------------------------------------------------------------#
# Create VPC to host the EKS Cluster #
resource "aws_vpc" "foundation" {
  cidr_block       = var.vpcCidrRange

  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "vpc"])
    }
  )
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create 2 pairs of Public & Private Subnets for the same VPC #
resource "aws_subnet" "pub_subnet_1" {
  vpc_id     = aws_vpc.foundation.id
  cidr_block = cidrsubnet(aws_vpc.foundation.cidr_block, 4, 1)
  
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = "true"

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "pub-subnet-1"])
    SubnetType = "Public-Subnet-1"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${join ("-", [var.deploymentPrefix,var.deployedRegion,"l1"])}" = "shared"
    }
  )
}

resource "aws_subnet" "pub_subnet_2" {
  vpc_id     = aws_vpc.foundation.id
  cidr_block = cidrsubnet(aws_vpc.foundation.cidr_block, 4, 2)
  
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = "true"

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "pub-subnet-2"])
    SubnetType = "Public-Subnet-2"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${join ("-", [var.deploymentPrefix,var.deployedRegion,"l1"])}" = "shared"
    }
  )
}

resource "aws_subnet" "pri_subnet_1" {
  vpc_id     = aws_vpc.foundation.id
  cidr_block = cidrsubnet(aws_vpc.foundation.cidr_block, 4, 3)

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "pri-subnet-1"])
    SubnetType = "Private-Subnet-1"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${join ("-", [var.deploymentPrefix,var.deployedRegion,"l1"])}" = "shared"
    }
  )
}

resource "aws_subnet" "pri_subnet_2" {
  vpc_id     = aws_vpc.foundation.id
  cidr_block = cidrsubnet(aws_vpc.foundation.cidr_block, 4, 4)
  
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "pri-subnet-2"])
    SubnetType = "Private-Subnet-2"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${join ("-", [var.deploymentPrefix,var.deployedRegion,"l1"])}" = "shared"
    }
  )
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create one Routing table to accomodate Public Subnets & 2 sets of
# Routing tables to individually host Private Subnets #
resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.foundation.id

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "pub-routing-table"])
    }
  )
}

resource "aws_route_table" "pri_route_table_1" {
  vpc_id = aws_vpc.foundation.id

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "pri-routing-table-1"])
    }
  )
}

resource "aws_route_table" "pri_route_table_2" {
  vpc_id = aws_vpc.foundation.id

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "pri-routing-table-2"])
    }
  )
}

resource "aws_route_table_association" "pubsubnetroutetableassociation1" {
  subnet_id      = aws_subnet.pub_subnet_1.id
  route_table_id = aws_route_table.pub_route_table.id
}

resource "aws_route_table_association" "pubsubnetroutetableassociation2" {
  subnet_id      = aws_subnet.pub_subnet_2.id
  route_table_id = aws_route_table.pub_route_table.id
}

resource "aws_route_table_association" "prisubnetroutetableassociation1" {
  subnet_id      = aws_subnet.pri_subnet_1.id
  route_table_id = aws_route_table.pri_route_table_1.id
}

resource "aws_route_table_association" "prisubnetroutetableassociation2" {
  subnet_id      = aws_subnet.pri_subnet_2.id
  route_table_id = aws_route_table.pri_route_table_2.id
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create a pair of Internet & NAT Gateway for the same VPC, to map
# them respectively to the Public & Private Routing Tables #
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.foundation.id

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "igw"])
    }
  )
}

resource "aws_eip" "elasticip_1" {
  vpc      = true

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "eip-1"])
    }
  )
}

resource "aws_nat_gateway" "natgw_1" {
  allocation_id = aws_eip.elasticip_1.id
  subnet_id     = aws_subnet.pub_subnet_1.id

  depends_on = [aws_internet_gateway.igw, aws_eip.elasticip_1]

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "natgw-1"])
    }
  )
}

resource "aws_eip" "elasticip_2" {
  vpc      = true

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "eip-2"])
    }
  )
}

resource "aws_nat_gateway" "natgw_2" {
  allocation_id = aws_eip.elasticip_2.id
  subnet_id     = aws_subnet.pub_subnet_2.id

  depends_on = [aws_internet_gateway.igw, aws_eip.elasticip_2]

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "natgw-2"])
    }
  )
}

resource "aws_route" "internetgatewayroute" {
  depends_on                = [aws_internet_gateway.igw]

  route_table_id            = aws_route_table.pub_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}

resource "aws_route" "natgatewayroute_for_pri_route_table_1" {
  depends_on                = [aws_nat_gateway.natgw_1]

  route_table_id            = aws_route_table.pri_route_table_1.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.natgw_1.id
}

resource "aws_route" "natgatewayroute_for_pri_route_table_2" {
  depends_on                = [aws_nat_gateway.natgw_2]

  route_table_id            = aws_route_table.pri_route_table_2.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.natgw_2.id
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create Security Group for the EKS cluster control plane.
# Also, Use this to attach to future node groups if created to manage the traffic flow within node group & within
# control plane #

# resource "aws_security_group" "eks_cluster_shared_node_sec_group" {
#   name        = join ("-", [var.deploymentPrefix, "cluster-shared-node-sec-group"])
#   description = "Security Group that would be mapped for shared node communication (between managed & unmanaged nodes) within cluster"
#   vpc_id      = aws_vpc.foundation.id

#   tags = merge(var.resourceTags,{
#     Name = join ("-", [var.deploymentPrefix, "cluster-shared-node-sec-group"])
#     SecurityGroupFor  = "eks-cluster-shared-node-sec-group"
#     }
#   )
# }

resource "aws_security_group" "eks_cluster_control_plane_sec_group" {
  name        = join ("-", [var.deploymentPrefix, "control-plane-sec-group"])
  description = "Security Group that would be mapped as Control Plane traffic flow within EKS cluster"
  vpc_id      = aws_vpc.foundation.id

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix, "control-plane-sec-group"])
    SecurityGroupFor  = "eks-cluster-control-plane-sec-group"
    }
  )
}

# resource "aws_security_group_rule" "self_ingress_rule_for_eks_cluster_shared_node_sec_group" {
#   description       = "A self rule which allows nodes to communicate with each other (all ports)"
#   type              = "ingress"
#   from_port         = "-1"
#   to_port           = "-1"
#   protocol          = "all"
#   security_group_id = aws_security_group.eks_cluster_shared_node_sec_group.id
#   self              = "true"
# }
 
# resource "aws_security_group_rule" "egress_rule_for_cluster_shared_node_sec_group" {
#   description       = "Allow outgoing traffic"
#   type              = "egress"
#   from_port         = "-1"
#   to_port           = "-1"
#   protocol          = "all"
#   security_group_id = aws_security_group.eks_cluster_shared_node_sec_group.id
#   cidr_blocks       = ["0.0.0.0/0"]
#}

resource "aws_security_group_rule" "self_ingress_rule_for_cluster_control_plane_sec_group" {
  description       = "A self rule which is attached to control plane network interfaces. We recommend that you add the cluster security group to all existing and future node groups."
  type              = "ingress"
  from_port         = "-1"
  to_port           = "-1"
  protocol          = "all"
  security_group_id = aws_security_group.eks_cluster_control_plane_sec_group.id
  self              = "true"
}

resource "aws_security_group_rule" "egress_rule_for_cluster_control_plane_sec_group" {
  description       = "Allow outgoing traffic"
  type              = "egress"
  from_port         = "-1"
  to_port           = "-1"
  protocol          = "all"
  security_group_id = aws_security_group.eks_cluster_control_plane_sec_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}
#--------------------------------------------------------------#

# ========================================================================================================================== #
