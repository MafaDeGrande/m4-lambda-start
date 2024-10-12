variable "name" {
  type        = string
  description = "Name of the aws lamda"
}

variable "env" {
  type = string
  description = "Name of the environment"
}

variable "bucket_name" {
  type = string
  description = "S3 bucket name"
}

variable "handler" {
  type = string
  description = "Function entrypoint in code"
}

variable "path" {
  type = string
  description = "Path to the function's deployment package within the local filesystem"
}

variable "key" {
  type = string
  description = "The output of the archive file"
}
