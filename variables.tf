variable "service_version" {
  default     = "v1.0.0"
  type        = string
  description = "The version of the service"
}

variable "service_domain" {
  type        = string
  description = "The 1st level of logical grouping of the service, e.g. 'api', 'web', 'db', etc."
  default     = "test"
}

variable "service_name" {
  type        = string
  description = "The 2nd level of logical grouping of the service, e.g. 'my-api', 'my-web', 'my-db', etc."
  default     = "my-service"
}

variable "service_environment" {
  type        = string
  description = "The 3rd level of logical grouping of the service, e.g. 'dev', 'test', 'prod', etc."
  default     = "local"
}

variable "parameter_store_list" {
  type    = list(string)
  default = []
}

variable "api_routes" {
  type = map(object({
    method         = string
    path           = string
    authorizer_key = optional(string)
  }))
  default = {}
}

variable "api_authorizers" {
  type = map(object({
    lambda_key              = optional(string, null)
    external_authorizer_arn = optional(string, null)
    external                = optional(bool, false)
    authorizer_type         = string
    identity_sources        = list(string)
    payload_format_version  = optional(string)
  }))
  default = {}
}

variable "dynamodb_table_list" {
  type = list(object({
    name      = string,
    key       = string,
    range_key = optional(string),
  }))
  default = []
}

variable "lambda_function_configuration" {
  type = map(object({
    lambda_memory_size   = optional(number),
    lambda_timeout       = optional(number),
    policies             = optional(list(string), []) # Keys from local.policy_statements
    triggers             = optional(list(string), []) # Keys from local.allowed_triggers
    event_source_mapping = optional(list(string), []) # Keys from local.event_source_mapping
  }))
  default = {}
}

variable "lambda_vpc_configuration" {
  description = "Configuration object for VPC, security group, and subnet filtering"
  type = object({
    vpc_name            = string                 # Specifies the name of the VPC to search for using the 'tag:Name' filter.
    security_group_name = string                 # Specifies the name of the security group to search for using the 'group-name' filter.
    subnet_tag_name     = optional(string)       # The tag key used to filter subnets within the selected VPC (e.g., 'Environment', 'Purpose').
    subnet_values       = optional(list(string)) # A list of tag values to match subnets against the 'subnet_tag_name' (e.g., ['prod', 'Private']).
  })
  default = null
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "The default tags for the service"
}


