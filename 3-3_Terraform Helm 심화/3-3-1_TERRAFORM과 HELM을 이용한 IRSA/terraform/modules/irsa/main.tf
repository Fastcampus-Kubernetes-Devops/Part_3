locals {
  serviceAccountName = "demo-sa"
}

resource "aws_iam_role" "demo_sa_role" {
  name = "${local.serviceAccountName}-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${var.oidc_provider}:aud" : "sts.amazonaws.com",
            "${var.oidc_provider}:sub" : "system:serviceaccount:default:${local.serviceAccountName}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "demo_sa_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.demo_sa_role.name
}
