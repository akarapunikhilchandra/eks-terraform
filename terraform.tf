resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-spot-cluster"
  region   = "us-east-1"

  managed_node_groups = [
    {
      name = "spot"

      instance_types = ["t3.medium"]
      spot_instance_pools = [
        {
          max_price = "0.1" # Set the maximum price for spot instances
        }
      ]

      min_size     = 3
      desired_size = 3
      max_size     = 3

      availability_zones = ["us-east-1d"]

      ssh = {
        public_key = file("~/chandra") # Replace this with the path to your public key file
      }
    }
  ]
}