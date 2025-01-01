# Terraform HTTP Service Project

This project uses Terraform to provision an AWS infrastructure that includes an EC2 instance running a Flask-based HTTP service. The service interacts with an S3 bucket to list its contents via an HTTP endpoint.

---

## Features

1. **EC2 Instance**:
   - Launches a t2.micro instance in the specified AWS region.
   - Configures the instance with a user-data script to set up a Flask application.

2. **IAM Role**:
   - Creates an IAM role with the `AmazonS3ReadOnlyAccess` policy to allow the EC2 instance to access S3.

3. **Security Groups**:
   - Allows traffic on ports 80 (HTTP), 5000 (Flask), and 22 (SSH).

4. **Flask Application**:
   - A Python Flask app that lists objects in an S3 bucket or specific folder.

---

## Prerequisites

- **AWS Account**: Ensure you have an AWS account and the AWS CLI configured.
- **Terraform Installed**: Install Terraform [here](https://www.terraform.io/downloads).
- **Key Pair**: Create an AWS EC2 key pair (e.g., `jenkins`) and ensure the `.pem` file is accessible.
- **Existing VPC**: Replace the `vpc_id` in `main.tf` with your VPC ID.
- **S3 Bucket**: Ensure the S3 bucket you want to access is already created.

---

## Setup Instructions

### Step 1: Clone the Repository
```bash
git clone https://github.com/<your-github-username>/terraform-http-service.git
cd terraform-http-service

