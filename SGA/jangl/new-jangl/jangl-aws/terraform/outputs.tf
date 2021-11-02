output "exhibitor.AWS_ACCESS_KEY_ID" {
  value = "${aws_iam_access_key.exhibitor.id}"
}

output "exhibitor.AWS_SECRET_ACCESS_KEY" {
  value = "${aws_iam_access_key.exhibitor.secret}"
}

output "exhibitor.AWS_REGION" {
  value = "${aws_s3_bucket.exhibitor.region}"
}

output "exhibitor.S3_BUCKET" {
  value = "${aws_s3_bucket.exhibitor.bucket}"
}


# For packer to build in
output "subnet.public.id" {
  value = "${module.az-d.public_subnet_id}"
}

output "vpc.default.id" {
  value = "${aws_vpc.default.id}"
}


output "nat.public_ip" {
  value = "${module.az-d.nat.public_ip}"
}

output "vpc.cidr" {
  value = "${aws_vpc.default.cidr_block}"
}

output "cloud_config.rendered" {
  value = "${data.template_file.cloud_config.rendered}"
}

output "vault_kms_unseal_key" {
  value = "${aws_kms_key.vault.id}"
}
