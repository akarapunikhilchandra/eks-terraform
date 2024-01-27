module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "eks-spot-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = "vpc-021a2ac87501570e4"
  subnet_ids               = ["subnet-0eff86e19581e95ec", "subnet-0b062e7252a2101ca"]  # Replace with correct subnet ID
  control_plane_subnet_ids = ["subnet-0eff86e19581e95ec", "subnet-0b062e7252a2101ca"]  # Replace with correct subnet ID

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["m5.large"]
      azs            = ["us-east-1a", "us-east-1d"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-073125d036cf8ebfd"]
  subnets            = ["subnet-0eff86e19581e95ec", "subnet-0b062e7252a2101ca"]
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:767398108107:certificate/6e931858-c773-4dbe-a54e-17696cc76d63"
}

