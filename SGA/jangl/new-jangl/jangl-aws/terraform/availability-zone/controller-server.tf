/* Control Nodes */

resource "aws_instance" "controller" {
  count = "${var.controller_server_count}"
  ami = "${var.ami}"
  instance_type = "${var.controller_server_instance_type}"
  subnet_id = "${aws_subnet.private.id}"
  iam_instance_profile = "${var.default_instance_profile}"
  vpc_security_group_ids = ["${var.default_security_group_id}"]
  user_data = "${var.cloud_config_user_data}"
  tags = {
    Name = "${var.resource_prefix}controller-${count.index}${var.resource_postfix}"
    Service = "controller"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
  root_block_device = {
    volume_size = "${var.controller_root_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  ebs_optimized = true
  lifecycle {
    ignore_changes = ["user_data", "ami", "instance_type"]
  }
}
