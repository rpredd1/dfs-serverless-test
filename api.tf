module "apigateway_v2_name" {
  source        = "git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming?ref=v1.0.0"
  name_prefix   = "${local.resource_prefix_name}-api"
  resource_type = "apigatewayv2_api"
}

module "apigateway_v2_authorizer_name" {
  source        = "git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming?ref=v1.0.0"
  for_each      = var.api_authorizers
  name_prefix   = "${local.resource_prefix_name}-${each.key}"
  resource_type = "apigatewayv2_authorizer"
}

module "apigateway_v2_authorizer_iam_role" {
  source        = "git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming?ref=v1.0.0"
  for_each      = var.api_authorizers
  name_prefix   = "${local.resource_prefix_name}-${each.key}"
  resource_type = "iam_role"
}

module "apigateway_v2_http" {
  source = "git::https://github.com/bayer-int/tlp-terraform-aws-apigateway-v2?ref=v1.0.0"
  count  = length(var.api_routes) > 0 ? 1 : 0
  name   = module.apigateway_v2_name.name
  routes = {
    for lambda_key, route in var.api_routes :
    "${route.method} ${route.path}" => {
      authorizer_key     = route.authorizer_key
      authorization_type = route.authorizer_key != null ? "CUSTOM" : "NONE"
      integration = {
        uri                    = module.lambda_function[lambda_key].lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    }
  }
  authorizers = {
    for authorizer_key, authorizer in var.api_authorizers :
    authorizer_key => {
      identity_sources                  = authorizer.identity_sources
      name                              = module.apigateway_v2_authorizer_name[authorizer_key].name
      authorizer_uri                    = authorizer.external ? "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${authorizer.external_authorizer_arn}/invocations" : module.lambda_function[authorizer.lambda_key].lambda_function_invoke_arn
      authorizer_credentials_arn        = authorizer.external ? aws_iam_role.invocation_role[authorizer_key].arn : null # Create role for external authorizer
      authorizer_payload_format_version = authorizer.payload_format_version
      authorizer_type                   = authorizer.authorizer_type
    }
  }
  tags = local.default_tags
}

# Create authorization credentials if authorizer is external
resource "aws_iam_role" "invocation_role" {
  for_each           = { for k, v in var.api_authorizers : k => v if v.external }
  name               = module.apigateway_v2_authorizer_iam_role[each.key].name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "invocation_policy" {
  for_each = { for k, v in var.api_authorizers : k => v if v.external }
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [each.value.external_authorizer_arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  for_each = { for k, v in var.api_authorizers : k => v if v.external }
  name     = "default"
  role     = aws_iam_role.invocation_role[each.key].id
  policy   = data.aws_iam_policy_document.invocation_policy[each.key].json
}
