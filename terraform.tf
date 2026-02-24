terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#  1. Random ID for Unique Bucket Name 
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

#  2. S3 Bucket for Dashboard Hosting 
resource "aws_s3_bucket" "cloudhawk_bucket" {
  # This generates a name like "cloudhawk-dashboard-a1b2c3d4"
  bucket        = "cloudhawk-dashboard-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# Configure S3 for Static Website Hosting
resource "aws_s3_bucket_website_configuration" "cloudhawk_website" {
  bucket = aws_s3_bucket.cloudhawk_bucket.id

  index_document {
    suffix = "dashboard.html"
  }
}

# Disable "Block Public Access"
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.cloudhawk_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.cloudhawk_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.cloudhawk_bucket.arn}/*"
      },
    ]
  })
}

#  3. Security Group 
resource "aws_security_group" "cloudhawk_sg" {
  name        = "cloudhawk-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#  4. EC2 Instance 
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "cloudhawk_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  # YOUR KEY NAME
  key_name = "your_key"

  iam_instance_profile = "LabInstanceProfile"
  security_groups      = [aws_security_group.cloudhawk_sg.name]

  #  AUTOMATIC CONFIGURATION SCRIPT 
  user_data = <<-EOF
              #!/bin/bash
              # 1. Install Web Server and Git
              dnf update -y
              dnf install -y httpd git
              systemctl start httpd
              systemctl enable httpd
              
              # 2. Fix permissions so the script can read logs
              chmod 755 /var/log/httpd
              chmod 644 /var/log/httpd/access_log
              
              # 3. Clone the Repo
              cd /home/ec2-user
              git clone https://github.com/Hirva-Desai-A/CloudHawk.git
              chown -R ec2-user:ec2-user CloudHawk
              cd CloudHawk

              # --- THE IMPORTANT PART: RENAMING VARIABLES ---
              # This command finds 'BUCKET_NAME="your-unique-bucket-name"'
              # and replaces it with YOUR actual bucket name.
              sed -i 's/BUCKET_NAME=".*"/BUCKET_NAME="${aws_s3_bucket.cloudhawk_bucket.id}"/' analyzer.sh
              
              # 4. Make scripts executable
              chmod +x analyzer.sh dashboard_looper.sh
              EOF

  tags = {
    Name = "CloudHawk-Server"
  }
}

#  5. Outputs 
output "ssh_command" {
  value       = "ssh -i bastionkey.pem ec2-user@${aws_instance.cloudhawk_server.public_ip}"
  description = "Use this to connect to your server."
}

output "dashboard_url" {
  value       = "http://${aws_s3_bucket.cloudhawk_bucket.bucket}.s3-website-us-east-1.amazonaws.com/dashboard.html"
  description = "View your live dashboard here."
}

output "traffic_generator_url" {
  value       = "http://${aws_instance.cloudhawk_server.public_ip}"
  description = "Visit this multiple times to generate traffic."
}
