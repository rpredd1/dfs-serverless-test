# Add np variables here

# service version (e.g. v1.0.0)
service_version = "v1.0.0"

# Service domain (ex. dfs, tlp, carbon)
service_domain = "carbon-test"

# Service name (ex. my-api, app1, app1-api)
service_name = "my-api-glgxj"

# service environment is the environment of the service
service_environment = "np"

# This is an optional configuration
# creates API Gateway and route(s) with Lambda Function integration
api_routes = {
  #   helloWorld = {
  #     method = "GET"
  #     path   = "/hello-world"
  #     authorizer_key = "local_custom_authorizer"
  #   }
  #   authorizer = {
  #     method         = "GET"
  #     path           = "/hello-world-test"
  #     authorizer_key = "external_authorizer"
  #   }
  # Add more routes as needed
}

# This is an optional configuration
# creates lambda authorizers to be used by API Gateway routes
api_authorizers = {
  #     local_custom_authorizer = {
  #       lambda_key             = "authorizer"
  #       authorizer_type        = "REQUEST"
  #       identity_sources       = ["$request.header.Authorization"]
  #       payload_format_version = "2.0"
  #     },
  #     tfa_multi_authorizer = {
  #       external_authorizer_arn = "arn:aws:lambda:us-east-1:935815431689:function:tlp-lambda-multi-authorizer-non-prod-v1Authorizer"
  #       external                = true
  #       authorizer_type         = "REQUEST"
  #       identity_sources        = ["$request.header.Authorization"]
  #       payload_format_version  = "1.0"
  #     }
  # Add more authorizers as needed
}


# This is an optional configuration
# creates SSM Parameter Store which will be loaded into the Lambda Function environment
parameter_store_list = [
  #"dd-api-key", // this will be loaded into the Lambda Function environment as DD_API_KEY
]

# This is an optional configuration
# this will create a DynamoDB Table and a SSM Parameter Store to store the table name
dynamodb_table_list = [
  #   {
  #     name : "users",
  #     key : "PK"
  #     range_key : "SK"
  #   }
  # Add more tables as needed
]

# This is an optional configuration
# leave this as empty object if you don't want to use Lambda Function custom configuration
lambda_function_configuration = {
#   helloWorld = { # key matches dir name (ex. functions/helloWorld)
#     lambda_memory_size = 512
#     policies           = ["dynamodb"] # grants access to DynamoDB using the dynamodb policy in locals.policy_statements
#     triggers           = ["APIGatewayAny"] # grants access for API invocation using the APIGatewayAny trigger in locals.allowed_triggers
#   }
  #     authorizer = {
  #       triggers = ["APIGatewayAny"]
  #     }
  # Add more lambda custom configurations as needed
}

# This is an optional configuration
# VPC configuration will be applied to all lambdas
# lambda_vpc_configuration = {
#   vpc_name            = "tlp-vpc-np"
#   security_group_name = "default"
#   subnet_tag_name     = "tag:Name"
#   subnet_values       = ["tlp-vpc-np-Private*"]
# }


# tlp_custom_authorizer_name = "tlp-lambda-multi-authorizer-non-prod-v1Authorizer"

# define the default tags for the resources
default_tags = {}

