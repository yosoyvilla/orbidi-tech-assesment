variable "name" {
  description = "The RDS instance identifier."
  type        = string
}

variable "database_name" {
  description = "The name of the database."
  type        = string
}

variable "username" {
  description = "Username for the RDS instance"
  type        = string
}

variable "engine" {
  description = "The database version to use. Allowed values for engine: \"mysql\", \"postgres\"."
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["mysql", "postgres"], var.engine)
    error_message = "Allowed values for engine: \"mysql\", \"postgres\"."
  }
}

variable "engine_version" {
  description = "The database engine version."
  type        = string
  default     = "14.10"
}

variable "instance_class" {
  description = "The RDS instance size ex: db.m5.large."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The storage size in GB."
  type        = number
  default     = 20
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the database in."
}

variable "db_subnet_group_name" {
  type        = string
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group."
}

variable "security_group_ids" {
  description = "Security groups to attach to the instance."
  type        = list(string)
  default     = []
}