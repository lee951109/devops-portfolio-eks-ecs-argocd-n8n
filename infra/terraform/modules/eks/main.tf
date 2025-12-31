# -----------------------------------------
# IAM Role for EKS Control Plane
# -----------------------------------------
# 이 Role은 EKS "컨트롤 플레인"이
# AWS 리소스를 제어할 수 있도록 하기 위한 권한.
resource "aws_iam_role" "cluster" {
  name = "${var.name}-eks-cluster-role"

  # assume_role_policy:
  # "어떤 서비스가 이 Role을 사용할 수 있는지" 정의
  #
  # 여기서는 eks.amazonaws.com(EKS 서비스)만
  # sts:AssumeRole 권한을 가짐
  #
  # jsonencode:
  # Terraform 객체(map)를 JSON 문자열로 변환
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # EKS 컨트롤 플레인이 이 Role을 사용
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# EKS 컨트롤 플레인에 필요한 AWS 관리형 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = merge(var.tags, {
    Name = var.name
  })

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# -----------------------------------------
# IAM Role for EKS Worker Nodes
# -----------------------------------------
# 이 Role은 EKS 워커 노드(EC2 인스턴스)가 사용하는 Role.
# - ECR에서 이미지 Pull
# - CNI(Network Interface) 설정
# - 클러스터와 통신
resource "aws_iam_role" "node" {
  name = "${var.name}-eks-node-role"

  # EC2 서비스가 이 Role을 Assume 가능
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# -----------------------------------------
# Worker Node에 필요한 AWS 관리형 정책들
# -----------------------------------------
resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    # 워커 노드 기본 권한
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    # VPC CNI 플러그인이 ENI를 제어하기 위한 권한
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    # ECR에서 컨테이너 이미지 Pull 권한
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.node.name
  policy_arn = each.value
}


# Managed Node Group
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = [var.node_instance_type]

  tags = merge(var.tags, {
    Name = "${var.name}-node-group"
  })

  depends_on = [aws_iam_role_policy_attachment.node_policies]
}