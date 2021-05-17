resource "aws_iam_role" "iam_role_for_organisation" {
  name               = "${var.function_prefix}LambdaOrgRole"
  assume_role_policy = file("${path.module}/policies/LambdaAssume.pol")
}


resource "aws_iam_role_policy" "iam_role_policy_for_organisation" {
  name = "${var.function_prefix}LambdaOrgPolicy"
  role = aws_iam_role.iam_role_for_organisation.id

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"S3Org",
            "Effect":"Allow",
            "Action":[
                "s3:PutObject",
                "s3:DeleteObjectVersion",
                "s3:DeleteObject"
            ],
            "Resource":"arn:aws:s3:::${var.destination_bucket}/*"
        },
        {
            "Sid":"OrgData",
            "Effect":"Allow",
            "Action":[
                "organizations:ListAccounts",
                "organizations:ListCreateAccountStatus",
                "organizations:DescribeOrganization",
                "organizations:ListTagsForResource",
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
            "Resource":"*"
        },
        {
            "Sid":"Logs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "assume",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::${var.management_account_id}:role/OrganizationLambdaAccessRole"
        }
    ]
}

EOF

}

