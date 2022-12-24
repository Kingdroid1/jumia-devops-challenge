provider "kubernetes" {
  host                   = aws_eks_cluster.jumia.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.jumia.certificate_authority[0].data)
}
############################
# EKS Cluster resources
############################
resource "aws_iam_role" "cluster_iam" {
  name = "jumia_cluster_iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_iam.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_iam.name
}

resource "aws_eks_cluster" "jumia" {
  name     = "jumia-prod"
  role_arn = aws_iam_role.cluster_iam.arn

  vpc_config {
    subnet_ids = [var.priv-subnet-1, var.priv-subnet-2, var.priv-subnet-3]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
  
}
################################################
# create private and public subnets in AZs
################################################
data "aws_availability_zones" "available" {
    state = "available"
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}

###############################################################
# cluster AddON resource (vpc-cni) - optional but recommended
###############################################################
resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.jumia.name
  addon_name   = "vpc-cni"
}

data "tls_certificate" "cluster_tls" {
  url = aws_eks_cluster.jumia.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.jumia.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "vpc-cni-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "cni_role_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc-cni-role.name
}

###########################################
# add worker nodegroup with IAM role
###########################################
resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

##################################################
resource "aws_eks_node_group" "cluster_node_group" {
  cluster_name    = aws_eks_cluster.jumia.name
  node_group_name = "cluster_node_group"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = [var.priv-subnet-1, var.priv-subnet-2, var.priv-subnet-3]
  instance_types = ["m5.large"]

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}
