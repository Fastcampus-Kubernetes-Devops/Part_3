provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}
data "aws_ami" "demo_eks_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_encryption_config = {}

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  manage_aws_auth_configmap = true

  eks_managed_node_groups = {
    demo = {
      name            = "demo-ng"
      use_name_prefix = true

      subnet_ids = var.private_subnets

      min_size     = 1
      max_size     = 2
      desired_size = 1

      ami_id                     = data.aws_ami.demo_eks_ami.id
      enable_bootstrap_user_data = true

      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.medium"]

      create_iam_role          = true
      iam_role_name            = "demo-ng-role"
      iam_role_use_name_prefix = true
    }
  }
}

resource "helm_release" "utility" {
  name       = "utility"
  chart      = "../demo-helm"
  namespace  = "kube-system"
  depends_on = [module.eks]
}
