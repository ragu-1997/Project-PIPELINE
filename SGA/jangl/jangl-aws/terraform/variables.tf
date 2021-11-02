variable "access_key" {
  description = "AWS access key"
}

variable "secret_key" {
  description = "AWS secret access key"
}

variable "region"     {
  description = "AWS region to host your network"
  default     = "us-east-1"
}

variable "cluster_tag_name" {
  description = "Cluster name for AWS tags"
  default = "production"
}

variable "main_availability_zone" {
  description = "main availability zone for cluster"
  default     = "d"
}

variable "security_group_name_default" {
  description = "Name for default Security Group"
  default     = "internal"
}

variable "security_group_name_nat" {
  description = "Name for nat Security Group"
  default     = "nat"
}

variable "security_group_name_web" {
  description = "Name for web Security Group"
  default     = "web"
}

variable "vpc_name" {
  description = "Name for VPC"
  default     = "default"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.128.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.128.8.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "10.128.9.0/24"
}

# this way we change the the AZs we use easily, in only one place
variable "az_letter" {
  description = "AZ letter"
  default     = "d"
}

variable "peering_vpc_owner" {
  description = "AWS account id for vpc peering"
  default = "436481353247"
}

variable "monitoring_vpc_id" {
  description = "used to filter out the monitoring network from vpc peers"
  default = "vpc-0a187adc0cc1212ee"
}

variable "monitoring_vpc_cidr" {
  description = "used to filter out the monitoring network from vpc peers"
  default = "10.130.0.0/16"
}

variable "awx_vpc_id" {
  description = "used to filter out the awx network from vpc peers"
  default = "vpc-5a484138"
}

variable "awx_vpc_cidr" {
  description = "used to filter out the awx network from vpc peers"
  default = "10.0.0.0/16"
}

variable "awx_security_group_id" {
  description = "used to filter out the awx network from vpc peers"
  default = "sg-06e29350609e7e2b7"
}

/* Custom CentOS 8 AMIs which are updated */
variable "ami" {
  description = "Base AMI to launch the instances with"
  default = "ami-01ca03df4a6012157"
}

variable "exhibitor_bucket_name" {
  description = "S3 bucket for exhibitor"
  default = "exhibitor-new2"
}

variable "exhibitor_bucket_user" {
  description = "IAM user for exhibitor"
  default = "exhibitor-user"
}

variable "exhibitor_bucket_policy_name" {
  description = "Policy for exhibitor"
  default = "exhibitor-policy"
}

# Profiles

variable "default_instance_profile" {
  description = "IAM instance profile"
  default = "consul_profile"
}

variable "resource_instance_profile" {
  description = "IAM instance profile"
  default = "resource_profile"
}

variable "resource_postfix" {
  description = "added to the end of all AWS resource names"
  default = ""
}

variable "resource_prefix" {
  description = "added to the beginning of all AWS instance names"
  default = ""
}

variable "controller_server_count" {
  description = "# of controller servers"
  default = "0"
}
variable "controller_server_instance_type" {
  default = "m5a.large"
}
variable "controller_server_ami" {
  description = "controller server AMI"
  default = "ami-01ca03df4a6012157"
}

variable "edge_server_count" {
  description = "# of edge servers"
  default = "0"
}
variable "edge_server_instance_type" {
  default = "m5a.large"
}
variable "edge_server_ami" {
  description = "edge server AMI"
  default = "ami-01ca03df4a6012157"
}

variable "kafka_zk_server_count" {
  description = "# of kafka zk servers"
  default = "0"
}
variable "kafka_zk_server_instance_type" {
  default = "m5a.large"
}
variable "kafka_zk_server_ami" {
  description = "kafka zookeeper server AMI"
  default = "ami-01ca03df4a6012157"
}

variable "kafka_server_count" {
  description = "# of kafka servers"
  default = "0"
}
variable "kafka_server_instance_type" {
  default = "m5a.2xlarge"
}
variable "kafka_server_ami" {
  description = "kafka server AMI"
  default = "ami-01ca03df4a6012157"
}

variable "kafka_connect_server_count" {
  description = "# of kafka connect servers"
  default = "0"
}
variable "kafka_connect_server_instance_type" {
  default = "m5a.large"
}
variable "kafka_connect_server_ami" {
  description = "kafka connect AMI"
  default = "ami-01ca03df4a6012157"
}

variable "kafka_connect_lsql_server_count" {
  description = "# of kafka connect lsql servers"
  default = "0"
}
variable "kafka_connect_lsql_server_instance_type" {
  default = "m5a.2xlarge"
}

variable "resource_server_count" {
  description = "# of resource servers"
  default = "0"
}
variable "resource_server_instance_type" {
  default = "m5a.2xlarge"
}
variable "resource_server_ami" {
  description = "resource server AMI"
  default = "ami-01ca03df4a6012157"
}

variable "vpn_server_count" {
  description = "# of vpn servers"
  default = "0"
}
variable "vpn_server_instance_type" {
  default = "m5a.large"
}
variable "vpn_server_ami" {
  description = "vpn server AMI"
  default = "ami-01ca03df4a6012157"
}

variable "vpn_gw_name" {
  description = "VPN Gateway Name"
  default = "Office-VPG"
}

variable "global_tag_key" {
  description = "AWS tag key added to all supported resources"
  default = "Version"
}

variable "global_tag_value" {
  description = "AWS tag value added to all supported resources"
  default = "4"
}

variable "cloud_config_run_command" {
  description = "Additional command to run on first boot"
  default = ""
}
