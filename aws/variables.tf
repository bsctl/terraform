variable "region" {
  type        = "string"
  description = "The region that you want to deploy"
  default     = "eu-west-1"
}

variable "amis" {
  type = "map"
  description = "The AMI used for machines"
  default = {
    "eu-west-1" = "ami-4ac6653d"
    "eu-central-1" = "ami-fd228a92"
  }
}

variable "types" {
  type = "map"
  description = "The instance type used for machines"
  default = {
    "eu-west-1" = "t1.micro"
    "eu-central-1" = "t2.nano"
  }
}