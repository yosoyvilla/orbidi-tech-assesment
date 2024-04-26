variable "name" {
  description = "Name of the VPC that will be created"
  type        = string
}

variable "cidr_block" {
  description = "The IPv4 CIDR block of the VPC. Must be /16."
  type        = string

  validation {
    condition     = endswith(var.cidr_block, "/16")
    error_message = "var.cidr_block must be a /16 network."
  }
}