locals {
  functions = toset([
    for file in fileset("${path.module}/sources/src/functions", "**/index.py") : dirname(file)
  ])
}

module "lambda_layer_name" {
  source        = "git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming?ref=v1.0.0"
  name_prefix   = "${local.resource_prefix_name}-layer"
  resource_type = "lambda_function"
}

module "lambda_function_name" {
  for_each      = local.functions
  source        = "git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming?ref=v1.0.0"
  name_prefix   = "${local.resource_prefix_name}-${lower(replace(each.value, "[^a-zA-Z0-9]", "-"))}"
  resource_type = "lambda_function"
}

module "lambda_layer" {
  source                   = "git::https://github.com/bayer-int/tlp-terraform-aws-lambda?ref=v1.0.0"
  create_layer             = true
  layer_name               = module.lambda_layer_name.name
  compatible_runtimes      = [local.runtime]
  compatible_architectures = ["arm64"]
  source_path = [
    {
      path             = "sources/src/layers/shared"
      pip_requirements = true
      prefix_in_zip    = "python" # required to get the path correct
    }
  ]
  runtime                      = local.runtime
  artifacts_dir                = "${path.root}/.terraform/${module.lambda_layer_name.name}-build/"
  trigger_on_package_timestamp = false
  tags                         = local.default_tags
}


module "lambda_function" {
  source                       = "git::https://github.com/bayer-int/tlp-terraform-aws-lambda?ref=v1.0.0"
  for_each                     = local.functions
  source_path                  = "sources/src/functions/${each.value}"
  function_name                = module.lambda_function_name[each.value].name
  handler                      = "index.handler"
  runtime                      = local.runtime
  publish                      = true
  trigger_on_package_timestamp = false
  architectures                = ["arm64"]
  timeout                      = try(var.lambda_function_configuration[each.value].lambda_timeout, 30)
  memory_size                  = try(var.lambda_function_configuration[each.value].lambda_memory_size, 512)
  layers                       = [module.lambda_layer.lambda_layer_arn]

  attach_network_policy = true
  vpc_config            = var.lambda_vpc_configuration

  attach_policy_statements = true
  policy_statements = merge(
    local.default_policy_statements, # policies default to all lambdas, e.g ssm to service params
    {
      for policy in try(var.lambda_function_configuration[each.value].policies, []) : policy => local.policy_statements[policy]
    }
  )
  allowed_triggers = {
    for trigger in try(var.lambda_function_configuration[each.value].triggers, []) : trigger => local.allowed_triggers[trigger]
  }

  event_source_mapping = {
    for event in try(var.lambda_function_configuration[each.value].event_source_mapping, []) : event => local.event_source_mapping[event]
  }

  cloudwatch_logs_retention_in_days = try(var.lambda_function_configuration[each.value].lambda_timeout, 3)
  environment_variables = {
    "SERVICE_DOMAIN"      = var.service_domain
    "SERVICE_NAME"        = var.service_name
    "SERVICE_ENVIRONMENT" = var.service_environment
    "FUNCTION_NAME"       = each.value
  }
  artifacts_dir = "${path.root}/.terraform/${module.lambda_function_name[each.value].name}-build/"

  tags = local.default_tags
}

locals {
  # Add policies for all Lambdas here
  default_policy_statements = {
    ssm = {
      effect = "Allow",
      actions : [
        "ssm:GetParametersByPath",
      ],
      resources = [
        "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:parameter/service/${var.service_domain}/${var.service_name}/${var.service_environment}/*",
      ]
    }
  }

  # Add specific policies for Lambdas here
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:Get*",
        "dynamodb:Put*",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:DescribeTable"
      ]
      resources = [
        for table in var.dynamodb_table_list :
        "arn:aws:dynamodb:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:table/${module.dynamodb_table_name[table.name].name}"
      ]
    }
  }

  # Add specific triggers for Lambdas here
  allowed_triggers = {
    APIGatewayAny = length(var.api_routes) > 0 ? {
      service    = "apigateway"
      source_arn = "${module.apigateway_v2_http[0].api_execution_arn}/*/*"
    } : {}
  }

  # Add specific event source maps for Lambdas here
  event_source_mapping = {}
}
