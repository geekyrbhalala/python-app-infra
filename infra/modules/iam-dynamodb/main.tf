variable "role_name_prefix" {
  description = "Prefix for the IAM role and policy names"
  type        = string
  default     = "ec2"
}

variable "aws_region" {
  description = "AWS region for the DynamoDB resource ARN"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "Specific DynamoDB table ARN to restrict access (optional; leave empty for all tables)"
  type        = string
  default     = ""
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile to attach to the EC2 instance"
  value       = aws_iam_instance_profile.ec2_dynamodb_profile.name
}

output "role_arn" {
  description = "ARN of the IAM role created"
  value       = aws_iam_role.ec2_dynamodb_role.arn
}

# IAM Role for EC2 to assume
resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "${var.role_name_prefix}-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.role_name_prefix}-dynamodb-role"
  }
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.role_name_prefix}-dynamodb-policy"
  description = "Policy to allow EC2 instance to interact with DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeTable",
          "dynamodb:CreateTable",  # Optional: Remove if not needed
          "dynamodb:ListTables"
        ]
        Resource = var.dynamodb_table_arn != "" ? var.dynamodb_table_arn : "arn:aws:dynamodb:${var.aws_region}:*:table/*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  role       = aws_iam_role.ec2_dynamodb_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

# Instance Profile to associate with EC2
resource "aws_iam_instance_profile" "ec2_dynamodb_profile" {
  name = "${var.role_name_prefix}-dynamodb-profile"
  role = aws_iam_role.ec2_dynamodb_role.name
}