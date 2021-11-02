
resource "aws_iam_instance_profile" "consul_profile" {
  name  = "${var.resource_prefix}consul_profile"
  role = "${aws_iam_role.consul_role.name}"
}

resource "aws_iam_role_policy" "consul_policy" {
  name = "${var.resource_prefix}consul_policy"
  role = "${aws_iam_role.consul_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "consul_role" {
  name = "${var.resource_prefix}consul_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


/* Resource Policy */

resource "aws_iam_instance_profile" "resource_profile" {
  name  = "${var.resource_prefix}resource_profile"
  role = "${aws_iam_role.resource_role.name}"
}

resource "aws_iam_role_policy" "resource_policy" {
  name = "${var.resource_prefix}resource_policy"
  role = "${aws_iam_role.resource_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RexRayMin",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:DeleteVolume",
        "ec2:DeleteSnapshot",
        "ec2:Describe*",
        "ec2:CopySnapshot",
        "ec2:DescribeSnapshotAttribute",
        "ec2:DetachVolume",
        "ec2:ModifySnapshotAttribute",
        "ec2:ModifyVolumeAttribute",
        "ec2:DescribeTags",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "resource_role" {
  name = "${var.resource_prefix}resource_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
