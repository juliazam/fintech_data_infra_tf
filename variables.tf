variable "project_name" {
    type = string
    description = "Project name, resource naming methods"
}

variable "environment" {
    type = string

    validation {
        condition = contains(["dev", "staging", "prod"], var.environment)
        error_message = "environment must be one of: dev, staging, prod."
    }
}

variable "db_password" {
    type      = string
    sensitive = true
}

locals {
    full_name = "${var.project_name}-${var.environment}"
}

output "project_name_output" {
    value = var.project_name
    description = "Displays the project name used for resource naming"
}

output "resource_prefix" {
    value = local.full_name
}