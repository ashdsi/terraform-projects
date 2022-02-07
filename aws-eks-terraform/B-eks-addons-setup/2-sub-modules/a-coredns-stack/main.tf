# ========================================================================================================================== #

#--------------------------------------------------------------#
# Render the template with a substituted value for EKS Cluster Name
resource "local_file" "parent_kubeconfig_file" {
    content   = data.template_file.kubeconfig.rendered
    filename  = "${path.module}/eks-cluster-config.yaml"
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Correct the annotation for the "coredns" deployment resource as in
# EKS, by default, this service is annotated to run with "EC2" instance #
resource "null_resource" "patch_coredns" {

  triggers = {
    check_for_local_rendered_template_file = md5(local_file.parent_kubeconfig_file.filename)
  }

  provisioner "local-exec" {
    when        = create
    interpreter = ["PowerShell", "-Command"]
    command     = "kubectl patch deployment coredns --type json -p='[{\"op\": \"replace\", \"path\": \"/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type\", \"value\": \"fargate\" }]' --kubeconfig=${local_file.parent_kubeconfig_file.filename} --namespace kube-system"
  }
}
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Correct the annotation for the "aws-node" service account on 
# your pre-existing EKS cluster for its exclusive usage with 
# OIDC's IAM Role #
# resource "null_resource" "annotate_sa_aws_node" {

#   triggers = {
#     check_for_local_rendered_template_file = md5(local_file.parent_kubeconfig_file.filename)
#   }

#   provisioner "local-exec" {
#     when        = create
#     interpreter = var.pipelineDeployment == "true" ? ["bash", "-c"] : ["PowerShell", "-Command"]
#     command     = "kubectl annotate --overwrite sa aws-node \"eks.amazonaws.com/role-arn=${data.aws_iam_role.eks_managed_account.arn}\" --kubeconfig=${local_file.parent_kubeconfig_file.filename} --namespace kube-system"
#   }
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Re-establish the EKS authentication during "terraform destroy" stage
# to compensate for the "only 15 mins" availability of STS token #
# resource "null_resource" "authenticate_to_eks_cluster" {

#   triggers = {
#     eks_cluster                               = var.eksClusterName
#     runtime_platform                          = var.pipelineDeployment
#     template_file                             = local_file.parent_kubeconfig_file.filename
#     wait_for_eks_auth_completion              = null_resource.wait_for_eks_auth_completion.id
#     wait_for_unpatch_coredns                  = null_resource.unpatch_coredns.id
#     wait_for_remove_orphan_coredns_replicaset = null_resource.destroy_orphan_coredns_rs.id
#   }

#   provisioner "local-exec" {
#     when        = destroy
#     interpreter = self.triggers.runtime_platform == "true" ? ["bash", "-c"] : ["PowerShell", "-Command"]
#     command     = "aws eks update-kubeconfig --kubeconfig=${self.triggers.template_file} --name=${self.triggers.eks_cluster}"
#   }
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Run "local-exec" to add a time delay (of 10 seconds) for the 
# completion of EKS authentication to the cluster, needed during
# terraform destruction stage #
# resource "null_resource" "wait_for_eks_auth_completion" {

#   triggers = {
#     runtime_platform                          = var.pipelineDeployment
#     wait_for_unpatch_coredns                  = null_resource.unpatch_coredns.id
#     wait_for_remove_orphan_coredns_replicaset = null_resource.destroy_orphan_coredns_rs.id
#   }

#   provisioner "local-exec" {
#     when        = destroy
#     interpreter = self.triggers.runtime_platform == "true" ? ["bash", "-c"] : ["PowerShell", "-Command"]
#     command     = "sleep 10"
#   }
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Re-adjust the annotation for the "coredns" deployment resource
# during "terraform destroy" stage, as we need to uninstall 
# coredns application from fargate cluster #
# resource "null_resource" "unpatch_coredns" {

#   triggers = {
#     runtime_platform                          = var.pipelineDeployment
#     template_file                             = local_file.parent_kubeconfig_file.filename
#     wait_for_remove_orphan_coredns_replicaset = null_resource.destroy_orphan_coredns_rs.id
#   }

#   provisioner "local-exec" {
#     when        = destroy
#     interpreter = self.triggers.runtime_platform == "true" ? ["bash", "-c"] : ["PowerShell", "-Command"]
#     command     = "kubectl patch deployment coredns --type json -p='[{\"op\": \"replace\", \"path\": \"/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type\", \"value\": \"ec2\" }]' --kubeconfig=${self.triggers.template_file} --namespace kube-system"
#   }
# }
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Remove the "orphan" coredns replicaset that remains running after
# unpatching coredns application; to be invoked only during
# "terraform destroy" stage #
# resource "null_resource" "destroy_orphan_coredns_rs" {

#   triggers = {
#     runtime_platform  = var.pipelineDeployment
#     template_file     = local_file.parent_kubeconfig_file.filename
#   }

#   provisioner "local-exec" {
#     when        = destroy
#     interpreter = self.triggers.runtime_platform == "true" ? ["bash", "-c"] : ["PowerShell", "-Command"]
#     command     = "kubectl delete rs --selector \"eks.amazonaws.com/component=coredns\" --kubeconfig=${self.triggers.template_file} --namespace kube-system"
#   }
# }
#--------------------------------------------------------------#

# ========================================================================================================================== #
