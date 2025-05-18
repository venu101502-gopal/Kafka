variable "region" {
  description = "AWS region to create resources"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "The VPC ID where the subnets will be created"
}

variable "key_name" {
  description = "The name of the EC2 Key Pair"
}

variable "availability_zone" {
  description = "The availability zone to launch resources in"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
}

variable "private_subnet_one_cidr" {
  description = "CIDR block for the first private subnet"
}

variable "private_subnet_two_cidr" {
  description = "CIDR block for the second private subnet"
}

variable "private_subnet_three_cidr" {
  description = "CIDR block for the third private subnet"
}
