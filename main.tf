provider "aws" {
  region = var.region
}

data "aws_ami" "kafka_client" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "kafka_client_sg" {
  name        = "kafka-client-sg"
  description = "Security Group for Kafka Client EC2 instance"

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: open access — consider locking this down
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "EC2KafkaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "msk_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonMSKFullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2MSKCFProfile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "kafka_client_ec2" {
  ami                    = data.aws_ami.kafka_client.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  security_groups        = [aws_security_group.kafka_client_sg.name]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOT
    #!/bin/bash
    set -eux

    apt update -y
    apt upgrade -y
    apt install -y python3.7 python3.7-venv python3.7-distutils unzip curl openjdk-8-jdk wget

    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1

    cd /home/ubuntu
    echo "export PATH=/home/ubuntu/.local/bin:\$PATH" >> /home/ubuntu/.bashrc

    mkdir -p kafka mm
    cd kafka
    wget https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz
    tar -xzf kafka_2.12-2.2.1.tgz
    cd ..

    curl -O http://packages.confluent.io/archive/5.3/confluent-5.3.1-2.12.zip
    unzip confluent-5.3.1-2.12.zip

    wget https://bootstrap.pypa.io/get-pip.py
    sudo -u ubuntu python3.7 get-pip.py --user
    sudo -u ubuntu /home/ubuntu/.local/bin/pip3 install boto3 awscli --user

    chown -R ubuntu:ubuntu kafka mm confluent-5.3.1 get-pip.py
  EOT

  tags = {
    Name = "KafkaClientEC2Instance"
  }
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = "MSKCluster"
  kafka_version          = "2.2.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    client_subnets = [
      aws_subnet.private_subnet_one.id,
      aws_subnet.private_subnet_two.id,
      aws_subnet.private_subnet_three.id,
    ]
    instance_type  = "kafka.m5.large"
    security_groups = [aws_security_group.kafka_client_sg.id]

    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
      in_cluster    = false
    }
  }

  enhanced_monitoring = "PER_TOPIC_PER_BROKER"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_one" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_one_cidr
  availability_zone = var.availability_zone
}

resource "aws_subnet" "private_subnet_two" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_two_cidr
  availability_zone = var.availability_zone
}

resource "aws_subnet" "private_subnet_three" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_three_cidr
  availability_zone = var.availability_zone
}
