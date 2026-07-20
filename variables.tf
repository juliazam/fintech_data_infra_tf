variable "project_name" {
    type = string
    description = "Project name, resource naming methods"
}

variable "environment" {
    type = string
    default = "dev"
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