/* Resource Nodes */

resource "aws_instance" "resource" {
  count = "${var.resource_server_count}"
  ami = "${var.ami}"
  instance_type = "${var.resource_server_instance_type}"
  subnet_id = "${aws_subnet.private.id}"
  iam_instance_profile = "${var.resource_instance_profile}"
  vpc_security_group_ids = ["${var.default_security_group_id}"]
  user_data = "${var.cloud_config_user_data}"
  tags = {
    Name = "${var.resource_prefix}resource-${count.index}${var.resource_postfix}"
    Service = "resource"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
  root_block_device = {
    volume_size = "${var.resource_root_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  ebs_block_device = {
    device_name = "xvdh"
    volume_size = "${var.resource_ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  lifecycle {
    ignore_changes = ["ebs_block_device", "user_data", "ami", "instance_type"]
  }
}
