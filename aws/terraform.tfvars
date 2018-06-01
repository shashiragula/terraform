aws_region = "us-east-1"
project_name = "ragulas-terraform"

vpc_cidr = "10.111.0.0/16"
public_cidrs = [
    "10.111.1.0/24",
    "10.111.2.0/24"
    ]
accessip = "0.0.0.0/0"
key_name = "tf_key"
public_key_path = "/home/ec2-user/.ssh/id_rsa.pub"
server_instance_type = "t2.micro"
instance_count = 2