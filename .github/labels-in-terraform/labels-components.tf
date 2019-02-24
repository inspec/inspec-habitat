# This file is custom to the train-habitat project

resource "github_issue_label" "component_train" {
  repository  = "${var.repo_name}"
  name        = "Component/Train"
  color       = "48bdb9" # aqua
  description = "Related to the Train connection"
}

resource "github_issue_label" "component_" {
  repository  = "${var.repo_name}"
  name        = "Component/"
  color       = "48bdb9" # aqua
  description = ""
}