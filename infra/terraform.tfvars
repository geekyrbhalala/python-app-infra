name        = "environment"
environment = "dev-1"

vpc_cidr             = "11.0.0.0/16"
vpc_name             = "dev-proj-ca-central-vpc-1"
cidr_public_subnet   = ["11.0.1.0/24", "11.0.2.0/24"]
cidr_private_subnet  = ["11.0.3.0/24", "11.0.4.0/24"]
ca_availability_zone = ["ca-central-1a", "ca-central-1b"]

ec2_ami_id = "ami-055943271915205db"

public_key = "aws-ec2-instance-key"

domain_name = "geekyrbhalala.online"