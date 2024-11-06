resource "aws_eks_cluster" "zero" {
  name = "zero"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
        aws_subnet.zero_one.id,
        aws_subnet.zero_two.id,
        aws_subnet.zero_three.id
    ]
  }

  depends_on = [ 
    aws_iam_role.eks_cluster_role,
   ]


}