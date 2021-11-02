/* VPN server */

resource "aws_instance" "vpn" {
  count = "${var.vpn_server_count}"
  ami = "${var.vpn_server_ami}"
  instance_type = "${var.vpn_server_instance_type}"
  subnet_id = "${aws_subnet.public.id}"
  iam_instance_profile = "${var.default_instance_profile}"
  vpc_security_group_ids = ["${var.default_security_group_id}", "${var.nat_security_group_id}"]
  user_data = "${var.cloud_config_user_data}"
  source_dest_check = false
  tags = {
    Name = "${var.resource_prefix}vpn${var.resource_postfix}"
    Service = "vpn"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
  root_block_device = {
    volume_size = "${var.vpn_root_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  lifecycle {
    ignore_changes = ["user_data", "ami", "instance_type", "tags"]
  }
}
