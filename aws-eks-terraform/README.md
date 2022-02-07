# aws-eks-terraform

This project houses the IaC related toolset used for the creation of the EKS on Fargate

# General Overview on the EKS Cluster components:
The IaC project can be deciphered based on **2 specific folders/components**

1. **Foundation setup** (_Creation of EKS Foundation cluster_)
2. **Supplementary setup** (_Addition of addon's/pluggable features for the already provisioned EKS cluster_)

## [Foundation setup](#foundation-setup)
### [Folder structure](#foundation-folder-structure)
### [Design Workflow](#foundation-design-workflow)
### [Deployment Steps](#foundation-deployment-steps)
## [Supplementary setup](#other-setup)
### [Folder structure](#supplementary-folder-structure)
### [Design Workflow](#supplementary-design-workflow)
### [Pre-requisites before deployment](#supplementary-prerequisites)
### [Deployment Steps](#supplementary-deployment-steps)
--
--
--


## <a name="foundation-setup"></a> Foundation setup

### <a name="foundation-folder-structure"></a> Folder Structure

```
aws-eks-terraform/A-eks-foundation-setup
```

### <a name="foundation-design-workflow"></a> Design Workflow
As part of the IaC modular workflow of the EKS Cluster creation, we now have modules that would be the foundation for the creation of the EKS cluster

* Create the necessary **IAM Roles** for EKS Cluster which are described below for reference
    * **EKS Service Role:** This is a custom IAM role that would be mapped to the EKS Cluster as a "Service Role", which would have permissions to interact with other AWS services like ELB, CloudWatch metrics, & even with VPC
    * **EKS Fargate Pod Exec Role:** This is a custom IAM role that would be mapped to the various Fargate profiles, which would grant privileges for the respective profile to interact with the pods spawned within the EKS cluster
    * **EKS OIDC Managed Role:** This is the last but significant custom IAM role created with "OIDC-web-identity" as a trusted entity, that would be mapped directly to the _service account_ of the EKS cluster node (_aws-node_), which ensures a handshake between the Identity provider (IdP) associated with the EKS cluster and the underlying EC2 nodes which are part of the cluster

:label: All the necessary IAM roles to securely administer the EKS cluster is created at this module

* Create the **Network stack** for EKS cluster, with a mix of **Public & Private** subnets, **security groups** (for cluster control plane), **Elastic IP, NAT Gateway & Internet Gateway**

:label: _For the creation of VPC, there is a variable named: **VPCCidrBlock**, which can take the CIDR for the custom VPC; based on that variable, the CIDR values for **public & private subnets** are **automatically sliced** and created across the Availability Zones of your chosen region._

* Create a **standard EKS foundation cluster**, and then map the "EKS cluster created" security group with new rules to help facilitate the traffic between the control plane & the cluster

* **Fargate**: Create a **standard EKS Fargate Tenant** profile to host various applications within EKS cluster. The set of profiles include

    * **fp-foundation:** to map to the default, kube-system namespace, 
    * **fp-coredns:** in order to maintain the service-discovery for coredns in kube-system namespace


* and finally create **a ECR repository** 

### <a name="foundation-deployment-steps"></a> Deployment Steps
:pushpin: **IMPORTANT:**

The below steps are created for deployment from local system (with Git Bash), and the values given here **are only for representation purpose.**

* **Step-1:** Navigate to the folder which has the parent module

```
aws-eks-terraform/A-eks-foundation-setup/1-main-module
```

* **Step-2:** Authenticate to AWS Account

```
export AWS_ACCESS_KEY_ID="Enter access key ID"; 
export AWS_SECRET_ACCESS_KEY="Enter secret access key"; 
export AWS_DEFAULT_REGION="us-east-1";
```
or if you have AWS CLI installed, configure the credential profile using aws configure. Terraform will use the default profile

* **Step-3:** Initialize terraform deployment (recommended with terraform managed states)

```
terraform init \
-backend-config="bucket=aws-to-project-tf-states" \
-backend-config="key=aws-eks-terraform/eks-setup/terraform.tfstate" \
-backend-config="region=us-east-1" \
-backend-config="dynamodb_table=aws-to-project-tf-locks"
```

or for local simply "terraform init"

* **Step-4:** Run to validate the terraform deployment
```
terraform plan --auto-approve --var-file=../dev-foundation.tfvars
```

* **Step-5:** Apply the terraform plan for deployment **(for MNG model of deployment)**

```
terraform apply --auto-approve --var-file=../dev-foundation.tfvars
```

* **Step-6:** And finally, once all the necessary AWS services are tested & validated, the same can be "un-deployed"

```
terraform destroy --auto-approve --var-file=../dev-foundation.tfvars
```

--- 

## <a name="other-setup"></a> Supplementary setup

### <a name="supplementary-folder-structure"></a> Folder Structure

```
aws-eks-terraform/B-eks-addons-setup
```

### <a name="supplementary-design-workflow"></a> Design Workflow

As part of the IaC modular workflow of the supplementary addons for the **already provisioned** EKS Cluster, we now have modules that would be seamlessly executed to manage the flow.

:pushpin: **ADD-ONs DESIGN:**

* Please ensure that you already have an EKS cluster with either of the compute models (**MNG or Fargate or both**) pre-created, before you attempt to deploy the supplementary
features on your cluster

* Patch the **service discovery module** (_coredns_) to ensure that its designed to discover & run the application workloads on a **EKS Cluster** of Fargate compute model (Activated only for **Fargate-based** compute model)

### <a name="supplementary-prerequisites"></a> Pre-requisites before deployment
Before you proceed to deploy the supplementary "add-ons" on the EKS cluster, please ensure that you have the following pre-requisite values already available

* **EKS Cluster Name:** Friendly name of the EKS cluster (which has already been provisioned in that chosen AWS account/region)

* **EKS Cluster Managed IAM Role Name:** Friendly name of the IAM Role, which will grant privileges for the 

:pushpin: **Important Note**

Earlier, we were relying on injecting **EKS OpenID Connect Provider URL** as a variable; this variable has now been deprecated, as its **automatically deduced** based on the EKS Cluster name.
```

### <a name="supplementary-deployment-steps"></a> Deployment Steps

:pushpin:
The below steps are created for deployment from local system (with Git Bash), and the values given here **are only for representation purpose.**

* **Step-1:** Navigate to the folder which has the parent module

```
aws-eks-terraform/B-eks-addons-setup/1-main-module
```

* **Step-2:** Authenticate to AWS Account

```
export AWS_ACCESS_KEY_ID="Enter access key ID"; 
export AWS_SECRET_ACCESS_KEY="Enter secret access key"; 
export AWS_DEFAULT_REGION="us-east-1";
```

* **Step-3:** Initialize terraform deployment (recommended with terraform managed states)

```
terraform init \
-backend-config="bucket=aws-to-project-tf-states" \
-backend-config="key=aws-eks-terraform/eks-configuration/terraform.tfstate" \
-backend-config="region=us-east-1" \
-backend-config="dynamodb_table=aws-to-project-tf-locks"
```

* **Step-4:** Plan the terraform deployment

 Terraform `local-exec` provisioner will run the steps with interpreter: **\["PowerShell", "-Command"\]** 

(suitable to be used for local workspace/work environ, as it would be on **"Windows"** flavor, where **PowerShell** is the preferred option)

:pushpin: **Important Note**


```
terraform plan --var-file=../../dev-supplementary.tfvars 
```

* **Step-5:** Apply the terraform plan first for generating the "kubeconfig" file to interact/configure with EKS cluster

We have "de-coupled" this step intentionally, to ensure that a similar workflow is adopted seamlessly during the DevOps Pipeline integration.

In this step, we would **dynamically generate** the "kubeconfig" file (along with a chosen context; using `--target="local_file.parent_kubeconfig_file"` flag)

This would be used extensively by the **IaC modules (Terraform) to interact with the pre-existing EKS cluster to create/configure any new resources/packages to it** (ex: creation of a EKS service account, deploying helm chart to setup AWS LB controller process, to name a few)

```
terraform apply --auto-approve --target="local_file.parent_kubeconfig_file" --var-file=../../dev-supplementary.tfvars 
```

* **Step-6:** Apply the terraform plan lastly for deployment of EKS Add-on's/supplementary features

```
terraform apply --auto-approve --var-file=../dev-supplementary.tfvars 
```

* **Step-7:** And finally, once all the necessary AWS services are tested & validated, the same can be "un-deployed"

```
terraform destroy --auto-approve --var-file=../dev-supplementary.tfvar
```

---
