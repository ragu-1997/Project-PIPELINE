
resource "aws_vpc_peering_connection" "monitoring" {
  peer_owner_id = "${var.peering_vpc_owner}"
  peer_vpc_id   = "${var.monitoring_vpc_id}"
  vpc_id        = "${aws_vpc.default.id}"
}

resource "aws_vpc_peering_connection" "awx" {
  peer_owner_id = "${var.peering_vpc_owner}"
  peer_vpc_id   = "${var.awx_vpc_id}"
  vpc_id        = "${aws_vpc.default.id}"
}
