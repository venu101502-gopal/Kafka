variable "region" {
  description = "AWS region to create resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "The VPC ID where the subnets will be created"
  type        = string
}

variable "key_name" {
  description = "The name of the EC2 Key Pair"
  type        = string
}

variable "availability_zone_1" {
  description = "Availability Zone for private subnet 1"
  type        = string
}

variable "availability_zone_2" {
  description = "Availability Zone for private subnet 2"
  type        = string
}

variable "availability_zone_3" {
  description = "Availability Zone for private subnet 3"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_one_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_two_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
}

variable "private_subnet_three_cidr" {
  description = "CIDR block for the third private subnet"
  type        = string
}
