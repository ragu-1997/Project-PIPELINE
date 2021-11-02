variable "cluster_tag_name" {
  description = "Cluster name for AWS tags"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
}

variable "peering_vpc_owner" {
  description = "AWS account id for vpc peering"
}

variable "monitoring_vpc_id" {
  description = "used to filter out the monitoring network from vpc peers"
}

variable "monitoring_vpc_cidr" {
  description = "CIDR Subnet for the monitoring vpc, used to establish peering and routing."
}

variable "monitoring_vpc_peering_id" {
  description = "CIDR Subnet for the monitoring vpc, used to establish peering and routing."
}

variable "awx_vpc_id" {
  description = "used to filter out the awx network from vpc peers"
}

variable "awx_vpc_cidr" {
  description = "used to filter out the monitoring network from vpc peers"
}

variable "awx_vpc_peering_id" {
  description = "used to filter out the monitoring network from vpc peers"
}

variable "awx_security_group_id" {
  description = "used to filter out the monitoring network from vpc peers"
}

/* Custom CentOS 7 AMIs which are updated */
variable "ami" {
  description = "Base AMI to launch the instances with"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "gateway_id" {}

variable "default_security_group_id" {
  description = "ID of the security group for all servers"
}

variable "default_instance_profile" {
  description = "IAM instance profile"
  default = "consul_profile"
}

variable "resource_instance_profile" {
  description = "IAM instance profile"
  default = "resource_profile"
}

variable "nat_security_group_id" {
  description = "ID of the security group for the NAT"
}

variable "vpc_gateway_id" {
  description = "VPC gateway ID"
}

variable "region" {
  description = "AWS region to host your network"
}

variable "availability_zone_letter" {
  description = "AZ letter for the subnets"
}

variable "resource_postfix" {
  description = "added to the end of all AWS resource names"
  default = ""
}

variable "resource_prefix" {
  description = "added to the beginning of all AWS instance names"
  default = ""
}

variable "ebs_volume_type" {
  default = "gp2"
}

variable "global_tag_key" {
  description = "AWS tag key added to all supported resources"
  default = "Version"
}

variable "global_tag_value" {
  description = "AWS tag value added to all supported resources"
  default = "4"
}

/* Controller */

variable "controller_server_count" {
  description = "# of controller servers"
  default = "0"
}
variable "controller_server_instance_type" {
  default = "m5a.large"
}
variable "controller_server_ami" {
  description = "controller server AMI"
}
variable "controller_root_volume_size" {
  description = "size is in gigabytes"
  default = "40"
}

/* Edge */

variable "edge_server_count" {
  description = "# of edge servers"
  default = "0"
}
variable "edge_server_instance_type" {
  default = "m5a.large"
}
variable "edge_server_ami" {
  description = "edge server AMI"
}
variable "edge_root_volume_size" {
  description = "size is in gigabytes"
  default = "20"
}

/* Kafka Zookeeper */

variable "kafka_zk_server_count" {
  description = "# of controller servers"
  default = "0"
}
variable "kafka_zk_server_instance_type" {
  default = "m5a.large"
}
variable "kafka_zk_server_ami" {
  description = "kafka zookeeper server AMI"
}
variable "kafka_zk_root_volume_size" {
  description = "size is in gigabytes"
  default = "40"
}

/* Kafka */

variable "kafka_server_count" {
  description = "# of kafka servers"
  default = "0"
}
variable "kafka_server_instance_type" {
  default = "m5a.2xlarge"
}
variable "kafka_server_ami" {
  description = "kafka server AMI"
}
variable "kafka_root_volume_size" {
  description = "size is in gigabytes"
  default = "20"
}
variable "kafka_ebs_volume_size" {
  description = "size is in gigabytes"
  default = "100"
}


/* Kafka Connect */

variable "kafka_connect_server_count" {
  description = "# of kafka connect servers"
  default = "0"
}
variable "kafka_connect_server_instance_type" {
  default = "m5a.2xlarge"
}
variable "kafka_connect_server_ami" {
  description = "kafka connect AMI"
}

variable "kafka_connect_lsql_server_count" {
  description = "# of kafka connect lsql servers"
  default = "0"
}
variable "kafka_connect_lsql_server_instance_type" {
  default = "m5a.2xlarge"
}

/* Resource */

variable "resource_server_count" {
  description = "# of resource servers"
  default = "0"
}
variable "resource_server_instance_type" {
  default = "m5a.2xlarge"
}
variable "resource_server_ami" {
  description = "resource server AMI"
}
variable "resource_root_volume_size" {
  description = "size is in gigabytes"
  default = "20"
}
variable "resource_ebs_volume_size" {
  description = "size is in gigabytes"
  default = "100"
}

/* VPN */

variable "vpn_server_count" {
  description = "# of vpn servers"
  default = "0"
}
variable "vpn_server_instance_type" {
  default = "m5a.large"
}
variable "vpn_server_ami" {
  description = "vpn server AMI"
}
variable "vpn_root_volume_size" {
  description = "size is in gigabytes"
  default = "8"
}

variable "cloud_config_user_data" {
  description = "cloud config user-data file"
  default = ""
}
