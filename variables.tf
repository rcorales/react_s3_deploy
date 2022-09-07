variable "prefix" {
  type = string
  description = "The name of the Environment"
}

variable "bucket_name" {
  type = string
  description = "The name of the bucket"
}

variable "aws_region" {
  type = string
  default = "ap-southeast-1"
}

variable "domain_name" {
  type = string
  description = "The name of the Domain"
}