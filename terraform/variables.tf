variable "app_image_id" {
  description = "Docker image ID for the Python application."
  type        = string
}

variable "gateway_image_id" {
  description = "Docker image ID for the NGINX gateway."
  type        = string
}

variable "host_port" {
  description = "Local port exposing the application gateway."
  type        = number
  default     = 8088
}
