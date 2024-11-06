resource "aws_eks_node_group" "zero" {
  cluster_name = aws_eks_cluster.zero.name
  node_group_name = "zero"
  node_role_arn = aws_iam_role.eks_node_role.arn
  subnet_ids = [
    aws_subnet.zero_one.id,
    aws_subnet.zero_two.id,
    aws_subnet.zero_three.id,
  ]
  capacity_type = "SPOT"

  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }
  
  update_config {
    max_unavailable = 1
  }

  depends_on = [ 
    aws_iam_role.eks_node_role,
   ]

}