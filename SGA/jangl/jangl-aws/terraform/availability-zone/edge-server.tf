/* Edge Nodes */

resource "aws_instance" "edge" {
  count = "${var.edge_server_count}"
  ami = "${var.edge_server_ami}"
  instance_type = "${var.edge_server_instance_type}"
  subnet_id = "${aws_subnet.private.id}"
  iam_instance_profile = "${var.default_instance_profile}"
  vpc_security_group_ids = ["${var.default_security_group_id}"]
  user_data = "${var.cloud_config_user_data}"
  tags = {
    Name = "${var.resource_prefix}edge-${count.index}${var.resource_postfix}"
    Service = "edge"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
  root_block_device = {
    volume_size = "${var.edge_root_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  lifecycle {
    ignore_changes = ["user_data", "ami", "instance_type"]
  }
}
