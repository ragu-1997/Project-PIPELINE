/* Exhibitor configures zookeeper with S3 so we need to make a user for it */

resource "aws_iam_user" "exhibitor" {
    name = "${var.exhibitor_bucket_user}"
    path = "/system/"
}

resource "aws_iam_access_key" "exhibitor" {
    user = "${aws_iam_user.exhibitor.name}"
}

resource "aws_iam_user_policy" "exhibitor" {
    name = "${var.exhibitor_bucket_policy_name}"
    user = "${aws_iam_user.exhibitor.name}"
    /* policy from https://github.com/Netflix/exhibitor/wiki/Shared-Configuration */
    policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetBucketAcl",
        "s3:GetBucketPolicy",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.exhibitor.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.exhibitor.id}"
      ]
    }
  ]
}
EOF
    depends_on = ["aws_s3_bucket.exhibitor"]

}

/* We also need an S3 bucket for it */
resource "aws_s3_bucket" "exhibitor" {
    bucket = "${var.exhibitor_bucket_name}"

    tags {
        Version = "${var.global_tag_value}"
    }
}
