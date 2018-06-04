#---------networking/main.tf-----------

data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "tf_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags {
        Name = "tf_vpc"
    }
}

# IGW
resource "aws_internet_gateway" "tf_internet_gateway" {
    vpc_id = "${aws_vpc.tf_vpc.id}"
    
    tags {
        Name = "tf_igw"
    }
}


# PUBLIC RT
resource "aws_route_table" "tf_public_rt" {
    vpc_id = "${aws_vpc.tf_vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.tf_internet_gateway.id}"
    }
    
    tags {
        Name = "tf_public_rt"
    }
}

# PRIVATE RT
resource "aws_default_route_table" "tf_private_rt" {
    default_route_table_id = "${aws_vpc.tf_vpc.default_route_table_id}"
    
    tags {
        Name = "tf_private_rt"
    }
}

# PUBLIC SUBNET
resource "aws_subnet" "tf_public_subnet" {
    count = 2
    vpc_id = "${aws_vpc.tf_vpc.id}"
    cidr_block = "${var.public_cidrs[count.index]}"
    map_public_ip_on_launch = true
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    
    tags {
        Name = "tf_public_${count.index + 1}"
    }
}

# PRIVATE SUBNET
resource "aws_subnet" "tf_private_subnet" {
    count = 2
    vpc_id = "${aws_vpc.tf_vpc.id}"
    cidr_block = "${var.private_cidrs[count.index]}"
    map_public_ip_on_launch = false
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    
    tags {
        Name = "tf_private_${count.index + 1}"
    }
}

resource "aws_db_subnet_group" "tf_db_subnet_group" {
  name       = "tf_db_subnet_group"
  subnet_ids = ["${aws_subnet.tf_private_subnet.*.id[0]}",
                "${aws_subnet.tf_private_subnet.*.id[1]}"
  ]

  tags {
    Name = "tf_db_subnet_group"
  }
}


# PRIVATE RT & SG ASSOCIATION
resource "aws_route_table_association" "tf_private_assoc" {
    count = "${aws_subnet.tf_private_subnet.count}"
    subnet_id = "${aws_subnet.tf_private_subnet.*.id[count.index]}"
    route_table_id = "${aws_default_route_table.tf_private_rt.id}"
}

resource "aws_security_group" "tf_private_sg" {
    name = "tf_private_sg"
    description = "Access to private instances"
    vpc_id = "${aws_vpc.tf_vpc.id}"
    
    
    # HTTP
    ingress {
        from_port = 0
        to_port   = 0
        protocol = "-1"
        cidr_blocks = ["${var.accessip}"]
    }
    
}


# PUBLIC RT & SG ASSOCIATION
resource "aws_route_table_association" "tf_public_assoc" {
    count = "${aws_subnet.tf_public_subnet.count}"
    subnet_id = "${aws_subnet.tf_public_subnet.*.id[count.index]}"
    route_table_id = "${aws_route_table.tf_public_rt.id}"
}

resource "aws_security_group" "tf_public_sg" {
    name = "tf_public_sg"
    description = "Access to public instances"
    vpc_id = "${aws_vpc.tf_vpc.id}"
    
    # SSH
    ingress {
        from_port = 22
        to_port   = 22
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }
    
    # HTTP
    ingress {
        from_port = 80
        to_port   = 80
        protocol = "tcp"
        cidr_blocks = ["${var.accessip}"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.accessip}"]
    }
}

#PUBLIC NACL
resource "aws_network_acl" "tf_public_nacl" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  subnet_ids = ["${aws_subnet.tf_public_subnet.*.id}"]
  
  # HTTP
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.accessip}"
    from_port  = 80
    to_port    = 80
  }

  # HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${var.accessip}"
    from_port  = 443
    to_port    = 443
  }
  
  # SSH
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${var.accessip}"
    from_port  = 22
    to_port    = 22
  }
  
    #HTTP
    egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.accessip}"
    from_port  = 80
    to_port    = 80
  }

  # HTTPS
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${var.accessip}"
    from_port  = 443
    to_port    = 443
  }

  tags {
    Name = "tf_public_nacl"
  }
}

# PRIVATE NACL
resource "aws_network_acl" "tf_private_nacl" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  subnet_ids = ["${aws_subnet.tf_private_subnet.*.id}"]

  # SSH  
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${var.vpc_cidr}"
    from_port  = 22
    to_port    = 22
  }

  # HTTP
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.accessip}"
    from_port  = 80
    to_port    = 80
  }

  # HTTPS
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${var.accessip}"
    from_port  = 443
    to_port    = 443
  }

  tags {
    Name = "tf_private_nacl"
  }
}