/* Default security group */
resource "aws_security_group" "default" {
  name = "${var.resource_prefix}${var.security_group_name_default}"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["${var.vpc_cidr}", "${var.awx_vpc_cidr}"]
}

  tags {
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}

/* Security group for the nat server */
resource "aws_security_group" "nat" {
  name = "${var.resource_prefix}${var.security_group_name_nat}"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet. Also allows outbound HTTP"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 1194
    to_port   = 1194
    protocol  = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}

/* Security group for the web */
resource "aws_security_group" "web" {
  name = "${var.resource_prefix}${var.security_group_name_web}"
  description = "Security group for web that allows web traffic from internet"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Cluster = "${var.cluster_tag_name}"
    Version = "${var.global_tag_value}"
  }
}
