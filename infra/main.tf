module "networking" {
  source               = "./modules/networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  ca_availability_zone = var.ca_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet
}

module "security_group" {
  source                     = "./modules/security-groups"
  ec2_sg_name                = "SG for EC2 to enable SSH(22) and HTTP(80)"
  vpc_id                     = module.networking.dev_proj_1_vpc_id
  public_subnet_cidr_block   = tolist(module.networking.public_subnet_cidr_block)
  ec2_sg_name_for_python_api = "SG for EC2 for enabling port 8080"
}

module "iam_dynamodb" {
  source           = "./modules/iam-dynamodb"
  role_name_prefix = "myapp-ec2"
  aws_region       = "ca-central-1"
}

module "ec2" {
  source                     = "./modules/ec2"
  ami_id                     = var.ec2_ami_id
  instance_type              = "t2.micro"
  tag_name                   = "Amazon Linux EC2"
  public_key                 = var.public_key
  subnet_id                  = tolist(module.networking.dev_proj_1_public_subnets)[0]
  sg_enable_ssh_https        = module.security_group.sg_ec2_sg_ssh_http_id
  ec2_sg_name_for_python_api = module.security_group.sg_ec2_for_python_api
  enable_public_ip_address   = true
  iam_instance_profile       = module.iam_dynamodb.instance_profile_name 
  user_data_install_python   = templatefile("./modules/template/ec2_python_app.sh", {})
}

module "lb_target_group" {
  source                   = "./modules/load-balancer-target-group"
  lb_target_group_name     = "dev-proj-1-lb-target-group"
  lb_target_group_port     = 5000
  lb_target_group_protocol = "HTTP"
  vpc_id                   = module.networking.dev_proj_1_vpc_id
  ec2_instance_id          = module.ec2.dev_proj_1_ec2_instance_id
}

module "alb" {
  source                          = "./modules/load-balancer"
  lb_name                         = "dev-proj-1-alb"
  is_external                     = false
  lb_type                         = "application"
  sg_enable_ssh_https             = module.security_group.sg_ec2_sg_ssh_http_id
  subnet_ids                      = tolist(module.networking.dev_proj_1_public_subnets)
  tag_name                        = "dev-proj-1-alb"
  lb_target_group_arn             = module.lb_target_group.dev_proj_1_lb_target_group_arn
  ec2_instance_id                 = module.ec2.dev_proj_1_ec2_instance_id
  lb_listner_port                 = 80
  lb_listner_protocol             = "HTTP"
  lb_listner_default_action       = "forward"
  lb_https_listner_port           = 443
  lb_https_listner_protocol       = "HTTPS"
  dev_proj_1_acm_arn              = module.aws_ceritification_manager.dev_proj_1_acm_arn
  lb_target_group_attachment_port = 5000
}

module "hosted_zone" {
  source          = "./modules/hosted-zone"
  domain_name     = var.domain_name
  aws_lb_dns_name = module.alb.aws_lb_dns_name
  aws_lb_zone_id  = module.alb.aws_lb_zone_id
}

module "aws_ceritification_manager" {
  source         = "./modules/certificate-manager"
  domain_name    = var.domain_name
  hosted_zone_id = module.hosted_zone.hosted_zone_id
}

