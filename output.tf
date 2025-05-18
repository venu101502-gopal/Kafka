output "kafka_client_public_dns" {
  description = "Public DNS of the Kafka client EC2 instance"
  value       = aws_instance.kafka_client_ec2.public_dns
}

output "msk_cluster_arn" {
  description = "ARN of the MSK cluster"
  value       = aws_msk_cluster.msk_cluster.arn
}

output "vpc_id" {
  description = "The VPC ID"
  value       = var.vpc_id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_one_id" {
  description = "Private Subnet One ID"
  value       = aws_subnet.private_subnet_one.id
}

output "private_subnet_two_id" {
  description = "Private Subnet Two ID"
  value       = aws_subnet.private_subnet_two.id
}

output "private_subnet_three_id" {
  description = "Private Subnet Three ID"
  value       = aws_subnet.private_subnet_three.id
}
