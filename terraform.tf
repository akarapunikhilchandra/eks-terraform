module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-spot-cluster"
  cluster_version = "1.20"
  subnets         = ["subnet-0eff86e19581e95ec", "subnet-0b062e7252a2101ca"]
  vpc_id          = "vpc-021a2ac87501570e4"

  node_groups = {
    eks_nodes = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = "chandra"

      k8s_labels = {
        Environment = "test"
        Name        = "eks-spot-cluster"
      }

      additional_tags = {
        Environment = "test"
        Name        = "eks-spot-cluster"
      }
    }
  }
}
