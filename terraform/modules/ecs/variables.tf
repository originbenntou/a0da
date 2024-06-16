variable "app_name" {
  type        = string
}

variable "image" {
  type        = string
}

variable "auth0_client_id" {
  type        = string
}

variable "auth0_client_secret" {
  type        = string
}

variable "auth0_domain" {
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "security_group_id" {
  type        = string
}

variable "target_group_arn" {
  type        = string
}

variable "execution_role_arn" {
  type        = string
}

variable "log_group_name" {
  type        = string
}