data "template_file" "cloud_config" {
  template = "${file("${path.root}/cloud-config.conf")}"

  vars {
    run_command = "${var.cloud_config_run_command}"
    exhibitor_aws_access_key_id = "${aws_iam_access_key.exhibitor.id}"
    exhibitor_aws_access_key_secret = "${aws_iam_access_key.exhibitor.secret}"
    exhibitor_aws_region = "${aws_s3_bucket.exhibitor.region}"
    exhibitor_aws_bucket = "${aws_s3_bucket.exhibitor.bucket}"
    openvpn_network_route = "${element(split("/", var.vpc_cidr), 0)}"
    kms_key = "${aws_kms_key.vault.id}"
  }
}
