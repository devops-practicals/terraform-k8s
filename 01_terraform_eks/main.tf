provider "aws" {
  region = "ap-south-1"
}

data "aws_availability_zones" "available" {}

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

locals {
  cluster_name = "devops-practicals-development"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# module "eks-kubeconfig" {
#   source  = "hyperbadger/eks-kubeconfig/aws"
#   version = "1.0.0"

#   depends_on = [module.eks]
#   cluster_id = module.eks.cluster_id
# }

# resource "local_file" "kubeconfig" {
#   content  = module.eks-kubeconfig.kubeconfig
#   filename = "kubeconfig_${local.cluster_name}"
# }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = "k8s-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.27"
  vpc_id  = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  eks_managed_node_group_defaults = {
    ami_type = "AL2_ARM_64"

  }
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t4g.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }
}