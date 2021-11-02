/* Public subnet */
resource "aws_subnet" "public" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "${var.region}${var.availability_zone_letter}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.resource_prefix}public-${var.availability_zone_letter}${var.resource_postfix}"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.gateway_id}"
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
    Name = "${var.resource_prefix}public-${var.availability_zone_letter}${var.resource_postfix}"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}

/* Associate the routing table to public subnet */
resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}
