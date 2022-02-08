# ========================================================================================================================== #

#--------------------------------------------------------------#
# Create ALB IAM Role + Policy Definition to map to EKS cluster #
resource "aws_iam_role" "oidc_web_role_for_alb" {
  name                = join ("-", [var.deploymentPrefix, "oidc","alb","controller","role"])
  description         = "This is a custom IAM Role with \"OIDC-Web-Identity\" as trusted entity, and will be used exclusively to connect AWS LB Controller to the EKS Cluster"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.oidc_web_trust_policy_for_alb.json

  tags = merge(var.resourceTags,{
    "IAMTagFor" = "OIDC-AWS-LB-Controller-Role"
    "Product" = "AWS-Identity-Authentication"
    "Service" = "IAM-Role"
    }
  )

}

resource "aws_iam_role_policy" "policy_for_alb_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  role = aws_iam_role.oidc_web_role_for_alb.id

  policy = file("${path.module}/iam-policy-templates/a-iam-alb-policy.json")
}

# Append additional IAM Policy which allows the AWS Load Balancer Controller to access the resources
# that were created by the ALB Ingress Controller for Kubernetes. May not be required for new cluster setup
resource "aws_iam_role_policy" "additional_policy_for_alb_controller" {
  name = "AWSLoadBalancerControllerAdditionalIAMPolicy"
  role = aws_iam_role.oidc_web_role_for_alb.id

  policy = file("${path.module}/iam-policy-templates/b-iam-alb-additional-append-policy.json")
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Render the template with a substituted value for EKS Cluster Name
resource "local_file" "parent_kubeconfig_file" {
    content   = data.template_file.kubeconfig.rendered
    filename  = "${path.module}/eks-cluster-config.yaml"
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Create a Service Account on your pre-existing cluster for exclusive usage to AWS LB Controller #
resource "kubernetes_service_account" "aws_lb_controller_sa" {

  depends_on  = [local_file.parent_kubeconfig_file]
  provider    = kubernetes.eks-foundation-cluster
  
  metadata {
    labels = {
      "app.kubernetes.io/component"   = "service-account"                     //mandatory
      "app.kubernetes.io/name"        = "aws-load-balancer-controller"        //mandatory
      "app.kubernetes.io/managed-by"  = "terraform"                           //optional
      "app.kubernetes.io/part-of"     = "AWS-ALB-Controller"                  //optional
    }
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.oidc_web_role_for_alb.arn
    }
  }
  automount_service_account_token = "true"
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Run helm charts to setup "cert-manager" for CA within EKS Cluster
# resource "helm_release" "cert_manager" {

#   depends_on = [local_file.parent_kubeconfig_file]
#   provider   = helm.public-chart-museum-eks-foundation-cluster

#   name       = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version    = "v1.1.1"
  
#   namespace = "cert-manager"
#   create_namespace = "true"

#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
  
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Run helm charts to setup "aws-alb-controller" within EKS Cluster
resource "helm_release" "aws_alb_controller" {
  
  depends_on = [local_file.parent_kubeconfig_file]
  provider   = helm.public-chart-museum-eks-foundation-cluster

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  
  namespace = "kube-system"

/*If you're deploying the controller to Amazon EC2 nodes that have restricted access to the Amazon EC2 instance metadata service (IMDS)

, or if you're deploying to Fargate, then add the following flags to the following command:

    --set region=region-code

    --set vpcId=vpc-xxxxxxxx

If you're deploying to any Region other than us-west-2, then add the following flag to the following command, replacing account and region-code with the values for your region listed in Amazon EKS add-on container image addresses. The cluster name can contain only alphanumeric characters (case-sensitive) and hyphens. It must start with an alphabetic character and can't be longer than 128 characters.

--set image.repository=account.dkr.ecr.region-code.amazonaws.com/amazon/aws-load-balancer-controller*/
  
  set {
    name  = "region"
    value = var.deployedRegion
  }

  set {
    name  = "vpcId"
    value = data.aws_eks_cluster.eks_name.vpc_config[0].vpc_id
  }

#Get account ID from here to get add-ons from based on region: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
#Here we used us-east-1
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.deployedRegion}.amazonaws.com/amazon/aws-load-balancer-controller"
  }



#If you deployed using the Kubernetes manifest, you only have one replica. 
#If deployed using Helm by default you have 2 replicas
#   set {
#     name  = "replicaCount"
#     value = "2"
#   }

#Set the below three as per documentation: https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
  set {
    name  = "clusterName"
    value = var.eksClusterName
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }


}
#--------------------------------------------------------------#

# ========================================================================================================================== #

#Deploy Sample Application

resource "kubectl_manifest" "test" {
    for_each  = toset(data.kubectl_path_documents.docs.documents)
    yaml_body = each.value
}

# resource "kubernetes_ingress_v1" "test_ingress" {
#   wait_for_load_balancer = true
#   metadata {
#     name = "ingress-2048"
#     namespace = "game-2048"
#     annotations = {
#         "alb.ingress.kubernetes.io/scheme" = "internet-facing"
#         "alb.ingress.kubernetes.io/target-type" = "ip"
#     }
#   }

#   spec {
#     ingress_class_name = "alb"
#     rule {
#       http {
#         path {
#           backend {
#             service {
#               name = "service-2048"
#               port {
#                   number = 80  
#               }
#             }
#           }

#           path = "/*"
#         }
#       }
#     }

#   }
# }
