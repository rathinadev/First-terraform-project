variable "cidr-vpc" {
description = "provides the cidr value for the VPC"  
}

variable "cidr-subnet" {
    description = "Provides the cidr value for the subnet under the demo vpc."
}
variable "key_pair" {
    description = "Proivdes the key pair for the infra."
  
}

variable "ami-value" {
    description = "provides ami value for the creation of instance"
  
}

variable "cidr" {
    description = "provides cidr block for route table"
  
}