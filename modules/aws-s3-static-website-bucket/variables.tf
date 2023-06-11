# Input variable definitions

variable "bucket_name" {
  description = "Name of the s3 bucket. Must be unique."
  type        = string
  default     = null
}

variable "bucket_preffix" {
  description = "Prefix for the s3 bucket name"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to set on the bucket."
  type        = map(string)
  default     = {}
}

variable "index_document_suffix" {
  description = "Suffix for index documnent."
  type        = string
  default     = "index.html"
}

variable "error_document_key" {
  description = "Key for error document."
  type        = string
  default     = "error.html"
}
