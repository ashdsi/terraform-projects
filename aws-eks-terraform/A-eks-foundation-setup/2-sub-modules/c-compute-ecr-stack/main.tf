# Create a user ECR repository
resource "aws_ecr_repository" "ecr_repo_user" {
  name                 = join ("-", [var.deploymentPrefix,"ecr","user"])
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.resourceTags,{
    Name = join ("-", [var.deploymentPrefix,"ecr","user"])
    }
  )
  
}


