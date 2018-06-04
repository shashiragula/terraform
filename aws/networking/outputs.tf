#---------networking/outputs.tf-----------

output "public_subnets" {
    value = "${aws_subnet.tf_public_subnet.*.id}"
}

output "public_sg" {
    value = "${aws_security_group.tf_public_sg.id}"
}

output "subnet_ips" {
    value = "${aws_subnet.tf_public_subnet.*.cidr_block}"
}

output "db_subnet_group_name" {
    value = "${aws_db_subnet_group.tf_db_subnet_group.id}"
}