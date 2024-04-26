variable "name" {
  description = "ECS identifier."
  type        = string
}

variable "environment_variables" {
  description = "A list of environment variables for the container."
  type        = list(map(string))
}

variable "environment_secrets" {
  description = "A list of Secrets Manager secrets for the container."
  type        = list(map(string))
}

variable "containerPort" {
  description = "The port that the container will listen on."
  type        = number
}

variable "hostPort" {
  description = "The host port that will be mapped to the container port."
  type        = number
}

variable "image" {
  description = "The URL of the container image to use."
  type        = string
}

variable "alb_subnets" {
  description = "A list of subnet IDs to associate with the Application Load Balancer (ALB)."
  type        = list(string)
}

variable "listener_certificate" {
  description = "The ARN of the SSL certificate to attach to the HTTPS listener."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources (including the ALB and security group) will be created."
  type        = string
}