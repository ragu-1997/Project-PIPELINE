/* Private subnet */
resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.region}${var.availability_zone_letter}"
  map_public_ip_on_launch = false
  depends_on = ["aws_nat_gateway.nat"]
  tags {
    Name = "${var.resource_prefix}private-${var.availability_zone_letter}${var.resource_postfix}"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }
  route {
    cidr_block = "${var.monitoring_vpc_cidr}"
    vpc_peering_connection_id = "${var.monitoring_vpc_peering_id}"
  }
  route {
    cidr_block = "${var.awx_vpc_cidr}"
    vpc_peering_connection_id = "${var.awx_vpc_peering_id}"
  }
  propagating_vgws = ["${var.vpc_gateway_id}"]
  tags {
    Name = "${var.resource_prefix}private-${var.availability_zone_letter}${var.resource_postfix}"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}

/* Associate the routing table to private subnet */
resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}
