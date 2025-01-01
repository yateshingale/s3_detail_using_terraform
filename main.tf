provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "http_sg" {
  name        = "http-sg-terraform"
  description = "Allow HTTP traffic"
  vpc_id      = "vpc-05fb4cd5406c5f4da"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_iam_role" "http_service_role" {
  name               = "http-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "http_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.http_service_role.name
}

resource "aws_iam_instance_profile" "http_service_profile" {
  name = "http-service-profile-terraform"
  role = aws_iam_role.http_service_role.name
}


resource "aws_instance" "http_service" {
  ami           = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  key_name      = "jenkins"
  security_groups = [aws_security_group.http_sg.name]
  iam_instance_profile = aws_iam_instance_profile.http_service_profile.name


  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3
              sudo pip3 install flask boto3
              cat > /home/ec2-user/app.py <<EOL
              from flask import Flask, jsonify
              import boto3
              import os

              app = Flask(__name__)
              s3 = boto3.client('s3')

              @app.route('/list-bucket-content/<path>', methods=['GET'])
              def list_bucket_content(path=''):
                  bucket_name = 'file-upload-notification'  # Replace with your S3 bucket name
                  content = []
                  try:
                      if path:
                          response = s3.list_objects_v2(Bucket=bucket_name, Prefix=path)
                      else:
                          response = s3.list_objects_v2(Bucket=bucket_name)

                      for obj in response.get('Contents', []):
                          content.append(obj['Key'].replace(path, '').lstrip('/'))

                  except Exception as e:
                      content.append(str(e))
                  return jsonify({'content': content})

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOL

              sudo python3 /home/ec2-user/app.py &
              EOF

  tags = {
    Name = "http-service-instance"
  }
}


output "http_service_public_ip" {
  value = aws_instance.http_service.public_ip
}
