provider "aws" {
  region = "us-east-1"
}

resource "aws_eks_cluster" "eks-spot-cluster" {
  name     = "eks-spot-cluster"
  region   = "us-east-1"

  launch_template {
    id      = aws_launch_template.eks-spot-cluster.id
    version = aws_launch_template.eks-spot-cluster.latest_version
  }

  node_groups = [
    {
      node_group_name = "spot"
      subnets         = aws_subnet.private.*.id
      min_size       = 3
      max_size       = 3
      desired_size   = 3
      ami_type       = "AL2_x86_64"
      disk_size      = 20
      instance_types = ["m5.large"]
      capacity_type  = "SPOT"
      key_name       = "chandra"
      ssh = {
        enable_ssh_key = true
      }
    }
  ]
}

resource "aws_launch_template" "eks-spot-cluster" {
  name = "eks-spot-cluster"

  image_id               = data.aws_ami.eks-worker.id
  instance_type          = "m5.large"
  vpc_security_group_ids = [aws_security_group.eks-spot-cluster.id]
  key_name               = "chandra"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
    }
  }
}

data "aws_ami" "eks-worker" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks-spot-cluster.version}-v*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["602401143452"] # Amazon EKS AMI account ID
}

resource "aws_security_group" "eks-spot-cluster" {
  name_prefix = "eks-spot-cluster"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  vpc_id = aws_vpc.eks-spot-cluster.id
}

resource "aws_vpc" "eks-spot-cluster" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-spot-cluster"
  }
}

resource "aws_subnet" "private" {
  count = 3

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.eks-spot-cluster.id

  tags = {
    Name = "eks-spot-cluster-private-${count.index + 1}"
  }
}