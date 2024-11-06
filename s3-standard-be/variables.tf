variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "project" {
  type = string
  default = "terraform-series"
  description = "The project name "
}

variable "principal_arns" {
  default = null
  type = list(string)
}