aws_region           = "eu-west-1"
environment          = "devopstht"
vpc_cidr             = "10.124.0.0/20"
availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
public_subnets_cidr  = ["10.124.0.0/23", "10.124.2.0/23", "10.124.4.0/23"]
private_subnets_cidr = ["10.124.6.0/23", "10.124.8.0/23", "10.124.10.0/23"]
