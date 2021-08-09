provider "docker" {}

provider "aws" {
  region = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = true
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "supermario-eks"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "docker_container" "ansible_container" {
  name    = var.ansible_container
  image   = docker_image.ansible_image.latest
  entrypoint = ["/app/run.sh"]
  env = ["AWS_ACCESS_KEY_ID=${var.aws_access_key_id}", "AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}", "AWS_DEFAULT_REGION=${var.region}"]
}

resource "docker_image" "ansible_image" {
  name = var.ansible_image
  build {
    path = var.ansible_dockerfile_path
    tag  = [var.ansible_image]
    label = {
      author : var.author
    }
  }
  depends_on = [module.eks-ingress-nginx]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.47"

  name                 = "supermario-eks-vpc"
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
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  tags = {
    Environment = "supermario"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  node_groups = {
    app = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_types = ["t2.small"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = "supermario"
      }
      additional_tags = {
        ExtraTag = "supermario"
      }
    }
  }

  map_roles = var.map_roles
  map_users = var.map_users
}

# module "alb-ingress-controller" {
#   source  = "iplabs/alb-ingress-controller/kubernetes"
#   version = "3.4.0"
#   k8s_cluster_type = "eks"
#   k8s_namespace    = "kube-system"
#   k8s_cluster_name = data.aws_eks_cluster.cluster.name
#   aws_region_name  = var.region
#   depends_on = [module.eks]
# }

module "eks-ingress-nginx" {
  source  = "lablabs/eks-ingress-nginx/aws"
  version = "0.2.0"
  mod_dependency = true
  depends_on = [module.eks]
}