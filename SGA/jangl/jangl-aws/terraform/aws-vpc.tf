/* Define our vpc */
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.resource_prefix}${var.vpc_name}${var.resource_postfix}"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.resource_prefix}${var.vpn_gw_name}"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}
