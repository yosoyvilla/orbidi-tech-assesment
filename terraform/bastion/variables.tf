variable "name" {
  description = "The Bastion identifier."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the bastion host will be deployed."
}

variable "subnet_id" {
  description = "The ID of the public subnet where the bastion host will be deployed."
}
