/* Kafka connect servers */

resource "aws_instance" "kafka-connect" {
  count = "${var.kafka_connect_server_count}"
  ami = "${var.ami}"
  instance_type = "${var.kafka_connect_server_instance_type}"
  subnet_id = "${aws_subnet.private.id}"
  iam_instance_profile = "${var.default_instance_profile}"
  vpc_security_group_ids = ["${var.default_security_group_id}"]
  user_data = "${var.cloud_config_user_data}"
  tags = {
    Name = "${var.resource_prefix}kafka-connect-${count.index}${var.resource_postfix}"
    Service = "kafka-connect"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
  root_block_device = {
    volume_size = "${var.resource_root_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  ebs_optimized = true
  lifecycle {
    ignore_changes = ["user_data", "ami", "instance_type"]
  }
}
