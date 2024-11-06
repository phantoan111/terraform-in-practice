resource "aws_eks_addon" "zero_vpccni" {
  cluster_name = aws_eks_cluster.zero.name
  addon_name = "vpc-cni"
  addon_version = "v1.18.5-eksbuild.1"
}

resource "aws_eks_addon" "zero_kubeproxy" {
  cluster_name = aws_eks_cluster.zero.name
  addon_name = "kube-proxy"
  addon_version = "v1.30.3-eksbuild.5"
}

resource "aws_eks_addon" "zero_coredns" {
  cluster_name = aws_eks_cluster.zero.name
  addon_name = "coredns"
  addon_version = "v1.11.1-eksbuild.11"
}