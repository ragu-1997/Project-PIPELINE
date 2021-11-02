/* VPC setup from https://www.airpair.com/aws/posts/ntiered-aws-docker-terraform-guide */

provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
}

terraform {
  backend "remote" {
    organization = "jangl"

    workspaces {
      prefix = "jangl-aws-"
    }
  }
}