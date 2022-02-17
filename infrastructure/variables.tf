variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "subnets" {
  type = list(map(string))
}

variable "subnets_secondary_ranges" {
  type = map(list(object({ range_name = string, ip_cidr_range = string })))
}

variable "tags" {
  type = map(list(string))
}

variable "environment" {
  type = string
}
