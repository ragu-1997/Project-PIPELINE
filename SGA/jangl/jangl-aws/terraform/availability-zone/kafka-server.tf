/* Kafka servers */

resource "aws_instance" "kafka" {
  count = "${var.kafka_server_count}"
  ami = "${var.ami}"
  instance_type = "${var.kafka_server_instance_type}"
  subnet_id = "${aws_subnet.private.id}"
  iam_instance_profile = "${var.default_instance_profile}"
  vpc_security_group_ids = ["${var.default_security_group_id}"]
  user_data = "${var.cloud_config_user_data}"
  tags = {
    KafkaID = "${count.index}"
    Name = "${var.resource_prefix}kafka-${count.index}${var.resource_postfix}"
    Service = "kafka"
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
  root_block_device = {
    volume_size = "${var.kafka_root_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.kafka_ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = "${var.kafka_ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  ebs_block_device {
    device_name = "/dev/sdd"
    volume_size = "${var.kafka_ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }
  lifecycle {
    ignore_changes = ["ebs_block_device", "user_data", "ami", "instance_type", "root_block_device"]
  }
}
