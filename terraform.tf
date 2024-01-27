module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-spot-cluster"
  cluster_version = "1.20"

  vpc_config = {
    subnets = ["subnet-0eff86e19581e95ec", "subnet-0b062e7252a2101ca"] # replace with your subnet ids
  }

  node_groups_defaults = {
    instance_type = "t3.medium"
    key_name      = "chandra"
    additional_tags = {
      Environment = "test"
      Name        = "eks-spot-cluster"
    }
  }

  node_groups = {
    eks_nodes = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1
    }
  }
}
