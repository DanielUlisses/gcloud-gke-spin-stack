variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "subnets" {
  type = list(map(string))
}

variable "tags" {
  type = map(list(string))
}

variable "environment" {
  type = string
}
