# aws_tf_organisation_data

The script schedules the collection of Aws Organization data and associated information like tags and OU's and places them into an Amazon S3 Bucket which can be accessed through AWS Athena.

This is to be used with the Amazon Cost and Usage report to give you more meta-data around your accounts.

It is the linked to the AWS Well Architected Lab: [ORGANIZATION DATA CUR CONNECTION](https://wellarchitectedlabs.com/cost/300_labs/300_organization_data_cur_connection/)
This can be deployed into your linked account or you management account depending on where you access your CUR. See optional inputs for how to do either. 


## Usage

```
module "aws_tf_organisation_data" {
  source = "github.com/awslabs/well-architected-lab300-aws-organization-data-terraform-module"
  destination_bucket = "Name-of-Bucket-to-create"
  tags = "BU,Env"
  management_account_id = "12345678901"
}
```

---
**NOTE**

If you wish to deploy to your linked account you will need to deploy a role to access your Organization in your Managment account. See below **Deploying into linked account**.

---

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| destination\_bucket | Name of existsing s3 bucket to put data in | string | `""` | yes |
| management\_account\_id | Managemant account ID holds your org data | string | `""` | yes |
| tags | Account level tags you wish to collect | string | `""` | yes |
| organisation\_cron | Rate expression for when to run the review of eips| string | `"ccron(0 6 ? * MON *)"` | no 
| function\_prefix | Prefix for the name of the lambda created | string | `""` | no |
| region | Region you are deploying in| string | `"eu-west-1"` | no |
| cur_database | The name of the database with your CUR table| string | `"managementcur"` | no |
| account | If you are deploying to Linked account do not need but if Management put in Management| string | `"Linked"` | no |
| memory\_size | Memory defined for lambda fucntion| string | `"512"` | no |
| timeout | Lambda Timeout| string | `"150"` | no |

## Prerequisites
- Access to the management AWS Account of the AWS Organisation to deploy a cross account role
- A sub account within the Organization
- Completed the Account Setup Lab [100_1_AWS_Account_Setup]({{< ref "/Cost/100_Labs/100_1_AWS_Account_Setup" >}})
- Completed the Cost and Usage Analysis lab [200_4_Cost_and_Usage_Analysis]({{< ref "/Cost/200_Labs/200_4_Cost_and_Usage_Analysis" >}})
- Completed the Cost Visualization Lab [200_5_Cost_Visualization]({{< ref "/Cost/200_Labs/200_5_Cost_Visualization" >}}) 


## Permissions required

Be able to create the below in the management account:
- IAM role and policy

Be able to create the below in a sub account where your CUR data is accessible:
- Amazon S3 Bucket 
- AWS Lambda function 
- IAM role and policy
- Amazon CloudWatch trigger
- Amazon Athena Table



## Deploying into linked account
If you are deploying into an AWS Linked account then you need to create a role in the Managment account to provied access to the lambda. The below can be deployed to the managment account.


```
variable "management_account_id" {
  type = number
  description = "Enter your sub account id which is where we started the lab"
}

resource "aws_iam_role" "role" {
  name = "OrganizationLambdaAccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${var.management_account_id}:role/LambdaOrgRole" }
    }]
  })
}

resource "aws_iam_policy" "policy" {
  name        = "organizations-permissons"
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
```


## Testing 

Configure your AWS credentials using one of the [supported methods for AWS CLI
   tools](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), such as setting the
   `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. If you're using the `~/.aws/config` file for profiles then export `AWS_SDK_LOAD_CONFIG` as "True".
1. Install [Terraform](https://www.terraform.io/) and make sure it's on your `PATH`.
1. Install [Golang](https://golang.org/) and make sure this code is checked out into your `GOPATH`.
cd test
go mod init github.com/sg/sch
go test -v -run TestTerraformAws

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

