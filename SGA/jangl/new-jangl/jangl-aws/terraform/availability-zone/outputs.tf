output "private_subnet_id" {
  value = "${aws_subnet.private.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "nat.public_ip" {
  value = "${aws_nat_gateway.nat.public_ip}"
}

