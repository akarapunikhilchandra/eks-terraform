resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-spot-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.21"  # Set your desired Kubernetes version

  vpc_config {
    subnet_ids = ["subnet-0eff86e19581e95ec"]
  }
}

resource "aws_eks_node_group" "spot_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "spot"

  node_role_arn = aws_iam_role.eks_node_group.arn
  subnet_ids    = ["subnet-0eff86e19581e95ec"]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  key_name       = "chandra"  # Replace this with your keypair exists in AWS
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster"
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks_node_group"
}
