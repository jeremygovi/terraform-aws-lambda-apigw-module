variable "project_name" {
  description = "The name of the project"
}

variable "source_path" {
  description = "Folder code"
}

variable "lambda_function_name" {
  description = "Lambda function name"
}

variable "lambda_runtime" {
  description = "Lambda runtime of function"
}

variable "environment_variables" {
  description = "Environment variables for lambda function"
  default     = {}
  type        = map
}

variable "api_gateway_name" {
  description = "API Gateway name"
}
