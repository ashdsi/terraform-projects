# output "alb_controller_profile" {
#   description = "Returns the Fargate profile used to setup AWS LB Controller application (for ingress setup) within EKS cluster"
#   value = aws_eks_fargate_profile.alb_controller_profile.id
# }

# output "cert_manager_profile" {
#   description = "Returns the Fargate profile used to setup cert-manager application (for webhook signing/authentication) within EKS cluster"
#   value = aws_eks_fargate_profile.cert_manager_profile.id
#}

output "foundation_profile" {
  description = "Returns the Fargate profile used to setup service discovery application (coredns) within EKS cluster"
  value = aws_eks_fargate_profile.foundation_profile.id
}
