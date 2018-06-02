Terraform code that would stand up the AWS VPC to include:

    1. Packer Build files that put a simple Java or Python app  an AMI ( apps can be cribbed from the internet )
    2. Modified to access the cache / db mentioned below a simple unit test works
    3. All components that the network requires to operate.
    4. One Ec2 Instance in both the Private and Public subnets ( built from the most recent copies of the amis that were built with packer
    5. RDS  instance
    6. Elasicache Redis Instance
    7. A simple Jenkins Pipeline DSL script that can run / report unit tests for one of the above applications.
