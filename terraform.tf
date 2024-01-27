provider "eksctl" {
  version = "0.1.0"
}

resource "eksctl_cluster" "eks_spot_cluster" {
  metadata = {
    name   = "eks-spot-cluster"
    region = "us-east-1"
  }

  managed_node_groups = [
    {
      name               = "spot"
      instance_type      = "t3.medium"
      spot               = true
      availability_zones = ["us-east-1d"]
      desired_capacity   = 3
      ssh                = {
        public_key_name = "chandra" # replace this with your keypair exists in AWS
      }
    },
  ]
}
