variable "hostname" {
  type    = list(string)
  default = ["k1-node1", "k1-node2", "k1-node3"]
}

variable "mac" {
  type    = list(string)
  default = ["00:00:00:00:00:31", "00:00:00:00:00:32", "00:00:00:00:00:33"]
}

variable "domain" {
  default = "local"
}

variable "memoryMB" {
  default = 1024*2 
}

variable "cpu" {
  default = 2
}

variable "GITLAB_USER_EMAIL" {
  type        = string
  description = "email address for gitlab annotation"
  default     = ""
}

variable "GITLAB_USER_NAME" {
  type        = string
  description = "gitlab username for creating annotation"
  default     = ""
}

variable "CI_PROJECT_URL" {
  type        = string
  description = "gitlab project url for creating annotation"
  default     = ""
}

variable "CI_PIPELINE_URL" {
  type        = string
  description = "gitlab project pipeline id for creating annotation"
  default     = ""
}
