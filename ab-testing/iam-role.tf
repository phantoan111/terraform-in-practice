resource "aws_iam_role" "lambda_edge" {
  name = "AWSLambdaEdgeRole"
  path = "/service-role/"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "edgelambda.amazonaws.com",
                    "lambda.amazonaws.com",
                ]
            },
            "Action": "sts:AssumeRole",
        }
    ]
  })
}

resource "aws_iam_policy" "lambda_edge" {
  name = "AWSLambdaPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect : "Allow",
            Action: [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
            ],
            Resource : [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_edge" {
  role = aws_iam_role.lambda_edge.name
  policy_arn = aws_iam_policy.lambda_edge.arn
}