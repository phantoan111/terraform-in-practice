variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  type = list(string)
}

variable "public_subnet" {
  type = list(string)
}

variable "avaiable_zone" {
  type = list(string)
}