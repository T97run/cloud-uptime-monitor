variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ca-central-1"
}


variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "uptime-monitor"
}


variable "urls" {
  type        = list(string)
  description = "List of URLs to check"
  default = [
"https://example.com",
"https://httpbin.org/get",
"https://google.com"
]
}


variable "schedule_expression" {
  type        = string
  description = "EventBridge schedule"
  default     = "rate(5 minutes)"
}


variable "runtime" {
  type    = string
  default = "python3.11"
}


variable "memory_mb" {
  type    = number
  default = 128
}


variable "timeout_seconds" {
  type    = number
  default = 10
}