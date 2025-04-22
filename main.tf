locals {
  runtime = "python3.12"
  default_tags = merge({
    "name" : "${var.service_domain}-${var.service_name}-${var.service_environment}",
    "environment" : var.service_environment,
    "service-name" : var.service_name,
    "service-domain" : var.service_domain,
    "service-version" : var.service_version,
    "tcc:service" : "${var.service_domain}-${var.service_name}-${var.service_environment}",
  }, var.default_tags)

  # define resources prefix name
  resource_prefix_name = substr(var.service_name, 0, length(var.service_domain)) == var.service_domain ? "${var.service_name}-${var.service_environment}" : "${var.service_domain}-${var.service_name}-${var.service_environment}"
}

resource "aws_ssm_parameter" "ssm_parameter_dynamodb_table" {
  for_each = { for table in var.dynamodb_table_list : table.name => table }
  name     = "/service/${var.service_domain}/${var.service_name}/${var.service_environment}/dynamodb-table-${each.value.name}" # prefixes table name with 'dynamodb-table-'
  type     = "SecureString"
  value    = module.dynamodb_table_name[each.value.name].name
  tags     = local.default_tags
}

resource "aws_ssm_parameter" "ssm_parameter_custom" {
  for_each = toset(var.parameter_store_list)
  name     = "/service/${var.service_domain}/${var.service_name}/${var.service_environment}/${each.value}"
  type     = "SecureString" # using aws managed key, (customer managed key incurs $1 a month **even if deleted before a month)
  value    = "placeholder"
  lifecycle {
    ignore_changes = [value] # value can be edited and terraform will not overwrite
  }
  tags = local.default_tags
}

resource "aws_ssm_parameter" "ssm_parameter_service_version" {
  name  = "/service/${var.service_domain}/${var.service_name}/${var.service_environment}/service-version"
  type  = "String"
  value = var.service_version
  tags  = local.default_tags
}
