package test

import (
	//"fmt"
	"testing"

	// "github.com/gruntwork-io/terratest/modules/aws"
	// "github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	//"github.com/stretchr/testify/assert"
	//"github.com/stretchr/testify/require"
)

// An example of how to test the Terraform module in examples/terraform-aws-example using Terratest.
func TestTerraformAwsExample(t *testing.T) {
	t.Parallel()

	// Give this lambda function a unique ID for a name so we can distinguish it from any other lambdas
	// in your AWS account
	// functionName := "scheduler_ec2_start" //, random.UniqueId()

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../aws_tf_organisation_data",
		
		// Variables to pass to our Terraform code using -var options
		
		Vars: map[string]interface{}{
			"function_prefix": "test",
			"bucket_name": "test",
			"tags": "test",
			"management_account_role_arn": "arn:aws:iam::12345678901:role/OrganizationLambdaAccessRole",
		},
		/*
		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		*/
	}

	// website::tag::4::At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
	/*
	// Invoke the function, so we can test its output
	response := aws.InvokeFunction(t, awsRegion, functionName, ExampleFunctionPayload{ShouldFail: false, Echo: "hi!"})

	// This function just echos it's input as a JSON string when `ShouldFail` is `false``
	assert.Equal(t, `"hi!"`, string(response))

	// Invoke the function, this time causing it to error and capturing the error
	response, err := aws.InvokeFunctionE(t, awsRegion, functionName, ExampleFunctionPayload{ShouldFail: true, Echo: "hi!"})
	
	// Function-specific errors have their own special return
	functionError, ok := err.(*aws.FunctionError)
	require.True(t, ok)

	// Make sure the function-specific error comes back
	assert.Contains(t, string(functionError.Payload), "Failed to handle")
	*//*
	testingTag, containsTestingTag := instanceTags["testing"]
	assert.True(t, containsTestingTag)
	assert.Equal(t, "testing-tag-value", testingTag)

	// Verify that our expected name tag is one of the tags
	nameTag, containsNameTag := instanceTags["Name"]
	assert.True(t, containsNameTag)
	assert.Equal(t, expectedName, nameTag)
	*/
}

type ExampleFunctionPayload struct {
	Echo       string
	ShouldFail bool
}