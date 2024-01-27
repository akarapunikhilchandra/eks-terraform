resource "aws_iam_role" "eks_cluster" {
  name = "eks-spot-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-spot-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
    security_group_ids = [
      aws_security_group.eks_cluster.id
    ]
  }

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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  count = 3

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "eks-spot-cluster-private-${count.index + 1}"
  }
}

resource "aws_security_group" "eks_cluster" {
  name        = "eks-spot-cluster"
  description = "EKS cluster security group"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}