variable "github_organization" {
  default = "inspec"
  type = "string"
}

variable "repo_name" {
  default = "inspec-habitat"
  type = "string"
}

variable "github_token" {
  # You can set env var TF_VAR_github_token to set this
  type = "string"
}