# Serverless Python Template (Terraform)

## Features
- Terraform code to provision the AWS Lambda project
- Boilerplate Python source code in the `sources` directory
- Automatically load AWS Secrets Manager (parameter store)
- Automatically load DynamoDB (table name)
- Lambda layer to store the dependencies of the project


## Resources
AWS Lambda Function, in the `functions.tf` there's a logic on creating AWS Lambda function based on files with format `**/index.py` under `sources/src/functions` directory, so the number of AWS Lambda function created is based on `**/index.py` files.

AWS API Gateway V2, in the `api.tf` there's a logic on creating AWS API Gateway V2 routes, integrations, and authorization set on `api_routes` and `api_authorizers` under `variables.tf`

AWS DynamoDB, in the `dynamodb.tf` there's a logic on creating AWS DynamoDB set on `dynamodb_table_list` under `variables.tf`

AWS System Manager Parameter Store, in the `main.tf` there's a logic on creating AWS Parameter Store with prefix set on `parameter_store_path` under `variables.tf` based on:
  - **parameter_store_list** attributes under `variables.tf` file
  - **dynamodb_table_list** attributes under `variables.tf` file which will create a Parameter Store to store the table names of DynamoDB with format `dynamodb-table-{table_name}`
  - **service_version** attributes under `variables.tf` file which will create a Parameter Store to store the version of the service


## Prerequisites
- Docker
  - [Install](https://docs.docker.com/engine/install/)
- Terraform
  - [Install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- AWS SSO
  - [Install](https://github.com/bayer-int/awssso)

  
## Testing

For best practice on testing serverless functions and applications:
https://docs.aws.amazon.com/lambda/latest/dg/testing-guide.html

## SonarQube

Go to https://sonar.cloud.bayer.com/ and find your repository under projects. For help accessing sonar.cloud.bayer, follow this [guide](https://docs.int.bayer.com/cloud/devops/sonarqube/setup/). From the project list, choose your project and generate the access token. Store this value in repository secrets as ``SONAR_TOKEN``. Additionally, in the `sonar-project.properties` file, update the ``projectKey`` to get the key stored under your projects settings in sonarqube.

## Versioning

This project version in package.json will be bumped on every release to main.

## Secrets Management

This repo will automatically create SSM Parameter Store for all paths under `parameter_store_list`. The parameters can be updated and pulled down once created. 

## AWS Setup

This template is configured to deploy off a Bayer SMART AWS account, that is configured with an OIDC provider, OIDC role, and Deploy role. This can be created by using this [building block](https://docs.int.bayer.com/cloud/building-blocks/github-oidc/github-oidc/). The pattern this template uses is the Single account pattern described in the building block. (Non-Prod and Production Account).

## Terraform

Infrastructure code (terraform) is contained within the repository. The terraform modules leveraged are located  [here](https://github.com/bayer-int/tlp-terraform-modules/tree/main) for further documentation on usage. These modules follow patterns from [serverless.tf](https://serverless.tf/).

## Deployment

Deployments are triggered on pushes to branches `np` and `main` using workflows in the .github/workflows directory. The `AWS_ACCOUNT_ID` and `DEPLOY_ROLE_ARN` environment variables need to be set in the np and prod environments for this to happen. Those values can be found by following the [aws setup](#aws-setup) section.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apigateway_v2_authorizer_iam_role"></a> [apigateway\_v2\_authorizer\_iam\_role](#module\_apigateway\_v2\_authorizer\_iam\_role) | git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming | v1.0.0 |
| <a name="module_apigateway_v2_authorizer_name"></a> [apigateway\_v2\_authorizer\_name](#module\_apigateway\_v2\_authorizer\_name) | git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming | v1.0.0 |
| <a name="module_apigateway_v2_http"></a> [apigateway\_v2\_http](#module\_apigateway\_v2\_http) | git::https://github.com/bayer-int/tlp-terraform-aws-apigateway-v2 | v1.0.0 |
| <a name="module_apigateway_v2_name"></a> [apigateway\_v2\_name](#module\_apigateway\_v2\_name) | git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming | v1.0.0 |
| <a name="module_dynamodb_table_name"></a> [dynamodb\_table\_name](#module\_dynamodb\_table\_name) | git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming | v1.0.0 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | git::https://github.com/bayer-int/tlp-terraform-aws-lambda | v1.0.0 |
| <a name="module_lambda_function_name"></a> [lambda\_function\_name](#module\_lambda\_function\_name) | git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming | v1.0.0 |
| <a name="module_lambda_layer"></a> [lambda\_layer](#module\_lambda\_layer) | git::https://github.com/bayer-int/tlp-terraform-aws-lambda | v1.0.0 |
| <a name="module_lambda_layer_name"></a> [lambda\_layer\_name](#module\_lambda\_layer\_name) | git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_role.invocation_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.invocation_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_ssm_parameter.ssm-parameter-custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.ssm-parameter-dynamodb-table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.ssm-parameter-service-version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.invocation_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.invocation_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_authorizers"></a> [api\_authorizers](#input\_api\_authorizers) | n/a | <pre>map(object({<br/>    lambda_key              = optional(string, null)<br/>    external_authorizer_arn = optional(string, null)<br/>    external                = optional(bool, false)<br/>    authorizer_type         = string<br/>    identity_sources        = list(string)<br/>    payload_format_version  = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_api_routes"></a> [api\_routes](#input\_api\_routes) | n/a | <pre>map(object({<br/>    method         = string<br/>    path           = string<br/>    authorizer_key = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | The default tags for the service | `map(string)` | `{}` | no |
| <a name="input_dynamodb_table_list"></a> [dynamodb\_table\_list](#input\_dynamodb\_table\_list) | n/a | <pre>list(object({<br/>    name      = string,<br/>    key       = string,<br/>    range_key = optional(string),<br/>  }))</pre> | `[]` | no |
| <a name="input_lambda_function_configuration"></a> [lambda\_function\_configuration](#input\_lambda\_function\_configuration) | n/a | <pre>map(object({<br/>    lambda_memory_size   = optional(number),<br/>    lambda_timeout       = optional(number),<br/>    policies             = optional(list(string), []) # Keys from local.policy_statements<br/>    triggers             = optional(list(string), []) # Keys from local.allowed_triggers<br/>    event_source_mapping = optional(list(string), []) # Keys from local.event_source_mapping<br/>  }))</pre> | `{}` | no |
| <a name="input_lambda_vpc_configuration"></a> [lambda\_vpc\_configuration](#input\_lambda\_vpc\_configuration) | Configuration object for VPC, security group, and subnet filtering | <pre>object({<br/>    vpc_name            = string                 # Specifies the name of the VPC to search for using the 'tag:Name' filter.<br/>    security_group_name = string                 # Specifies the name of the security group to search for using the 'group-name' filter.<br/>    subnet_tag_name     = optional(string)       # The tag key used to filter subnets within the selected VPC (e.g., 'Environment', 'Purpose').<br/>    subnet_values       = optional(list(string)) # A list of tag values to match subnets against the 'subnet_tag_name' (e.g., ['prod', 'Private']).<br/>  })</pre> | `null` | no |
| <a name="input_parameter_store_list"></a> [parameter\_store\_list](#input\_parameter\_store\_list) | n/a | `list(string)` | `[]` | no |
| <a name="input_service_domain"></a> [service\_domain](#input\_service\_domain) | The 1st level of logical grouping of the service, e.g. 'api', 'web', 'db', etc. | `string` | `"test"` | no |
| <a name="input_service_environment"></a> [service\_environment](#input\_service\_environment) | The 3rd level of logical grouping of the service, e.g. 'dev', 'test', 'prod', etc. | `string` | `"local"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The 2nd level of logical grouping of the service, e.g. 'my-api', 'my-web', 'my-db', etc. | `string` | `"my-service"` | no |
| <a name="input_service_version"></a> [service\_version](#input\_service\_version) | The version of the service | `string` | `"v1.0.0"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
