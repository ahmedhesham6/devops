# Infrastructure as Code (IaC) and Terraform for AWS

## Introduction to Infrastructure as Code (IaC)

Infrastructure as Code (IaC) is a practice in which infrastructure is provisioned and managed using code and software development techniques, such as version control and continuous integration. This approach allows developers and operations teams to automatically manage and provision technology stacks through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

Key benefits of IaC include:

1. Consistency and reproducibility
2. Version control and history
3. Automated deployment and scaling
4. Documentation of infrastructure
5. Faster recovery in case of disasters

## Terraform: An IaC Tool

Terraform is an open-source IaC tool created by HashiCorp. It allows you to define and provide data center infrastructure using a declarative configuration language. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.

## Using Terraform with AWS

Let's explore how we can use Terraform to create the AWS infrastructure described in the previous document.

### Basic Terraform Structure

A typical Terraform project for AWS might look like this:

```bash
project_root/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

- `main.tf`: Contains the main set of configuration for your module
- `variables.tf`: Contains declarations of variables used in the module
- `outputs.tf`: Contains outputs from the resources created
- `terraform.tfvars`: The file to populate variables with actual values

### Defining AWS Provider

First, we need to specify the AWS provider in our `main.tf`:

```hcl
provider "aws" {
  region = var.aws_region
}
```

### Creating Key AWS Components with Terraform

Now, let's look at how we can create some of the key AWS components using Terraform:

#### 1. EC2 (Elastic Compute Cloud)

```hcl
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "WebServer"
  }
}
```

#### 2. S3 (Simple Storage Service)

```hcl
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name = "Data Bucket"
  }
}
```

#### 3. RDS (Relational Database Service)

```hcl
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
}
```

#### 4. VPC (Virtual Private Cloud)

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}
```

#### 5. IAM (Identity and Access Management)

```hcl
resource "aws_iam_user" "example" {
  name = "example-user"
}

resource "aws_iam_user_policy" "example_policy" {
  name = "example-policy"
  user = aws_iam_user.example.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
```

#### 6. Elastic Load Balancer (ELB)

```hcl
resource "aws_elb" "web_elb" {
  name               = "web-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.web_server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "web-elb"
  }
}
```

#### 7. CloudFront

```hcl
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.data_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.data_bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.data_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

## Deploying the Infrastructure

To deploy this infrastructure:

1. Initialize Terraform:

   ```hcl
   terraform init
   ```

2. Plan the changes:

   ```hcl
   terraform plan
   ```

3. Apply the changes:

   ```hcl
   terraform apply
   ```

## Conclusion

Infrastructure as Code, and specifically Terraform, provides a powerful way to define, version, and manage cloud infrastructure. By using Terraform with AWS, we can create reproducible, scalable, and maintainable infrastructure setups. This approach aligns closely with DevOps practices, allowing for better collaboration between development and operations teams, faster deployments, and more reliable infrastructure management.
