/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name = "${var.resource_prefix}default${var.resource_postfix}"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}
