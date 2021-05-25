variable "linked_account_id" {
  type        = number
  description = "Enter your sub account id which is where we started the lab"
}

variable "function_prefix" {
  description = "only needed if you used in main deployment"
  default = ""
}

resource "aws_iam_role" "role" {
  name = "OrganizationLambdaAccessRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.linked_account_id}:role/${var.function_prefix}LambdaOrgRole"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "policy" {
  name   = "organizations-permissons"
  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Action": [
"organizations:ListAccountsForParent",
"organizations:ListRoots",
"organizations:ListCreateAccountStatus",
"organizations:ListAccounts",
"organizations:ListTagsForResource",
"organizations:DescribeOrganization",
"organizations:DescribeOrganizationalUnit",
"organizations:DescribeAccount",
"organizations:ListParents",
"organizations:ListOrganizationalUnitsForParent",
"organizations:ListChildren"
],
"Resource": "*",
"Effect": "Allow"
}
]
}
EOF
}


resource "aws_iam_role_policy_attachment" "attach-organizations-permissons" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
resource "aws_iam_role_policy_attachment" "attach-AWSLambdaExecute" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}