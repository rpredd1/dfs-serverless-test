module "dynamodb_table_name" {
  for_each      = { for table in var.dynamodb_table_list : table.name => table }
  source        = "git::https://github.com/bayer-int/tlp-terraform-aws-resource-naming?ref=v1.0.0"
  name_prefix   = "${local.resource_prefix_name}-${each.value.name}"
  resource_type = "dynamodb_table"
}

resource "aws_dynamodb_table" "dynamodb_table" {
  for_each = { for table in var.dynamodb_table_list : table.name => table }

  name         = module.dynamodb_table_name[each.value.name].name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = each.value.key
  range_key    = each.value.range_key != null ? each.value.range_key : null

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = each.value.key
    type = "S"
  }

  #   lifecycle {
  #     prevent_destroy = true
  #   }

  dynamic "attribute" {
    for_each = each.value.range_key != null ? [each.value.range_key] : []
    content {
      name = each.value.range_key
      type = "S"
    }
  }
  tags = local.default_tags
}
