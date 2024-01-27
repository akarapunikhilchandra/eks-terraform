resource "aws_iam_role" "node" {
  name = "eks-spot-cluster-node"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "eks-spot-cluster-node"
  role = aws_iam_role.node.name
}

resource "aws_launch_configuration" "spot" {
  name_prefix     = "eks-spot-cluster-spot-"
  image_id        = data.aws_ami.eks_node.id
  instance_type   = "m5.large"
  iam_instance_profile = aws_iam_instance_profile.node.name
  security_groups = [aws_security_group.node.id]
  # user_data_base64 = base64gz("${file("userdata.sh")}")

  spot_price = "0.083" # replace this with your desired spot price

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "eks_node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_iam_role.node.name}-*"]
  }

  most_recent = true
  owners      = ["767398108107"] # Amazon EKS AMI account ID
}

resource "aws_autoscaling_group" "spot" {
  name                      = "eks-spot-cluster-spot"
  launch_configuration      = aws_launch_configuration.spot.name
  availability_zones        = ["us-east-1d"]
  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  tag {
    key                 = "Name"
    value               = "eks-spot-cluster-node"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-group"
    value               = aws_iam_role.node.name
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s-app"
    value               = "cluster-autoscaler"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "node" {
  name_prefix = "eks-spot-cluster-node-"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}