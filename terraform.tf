module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-spot-cluster"
  subnets         = ["subnet-0eff86e19581e95ec"]
  vpc_id          = "vpc-021a2ac87501570e4"
  cluster_version = "1.21"  # Set your desired Kubernetes version

  node_groups = {
    spot = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1

      key_name = "chandra"  # Replace this with your keypair exists in AWS
      instance_type = "t3.medium"
    }
  }
}
