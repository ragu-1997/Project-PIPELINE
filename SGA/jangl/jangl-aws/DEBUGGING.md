# Debugging

<!-- use MarkdownTOC package in sublime text to update automatically on save -->
<!-- MarkdownTOC depth=5 autolink=true bracket=round -->

- [Logs](#logs)
  - [Docker Logs](#docker-logs)
  - [Syslog](#syslog)
- [Wiping](#wiping)
  - [Consul](#consul)
  - [Mesos Slave](#mesos-slave)
- [Refreshing](#refreshing)
  - [NGINX](#nginx)

<!-- /MarkdownTOC -->

## Logs

### Docker Logs

All docker logs are fed into Kafka.

You can look at them with

```bash
ssh -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate kafka.ip) "kafka-console-consumer --zookeeper $(terraform output -state=terraform/terraform.tfstate controller.ip):2181 --t docker-logs"
```

### Syslog

```bash
ssh -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate kafka.ip) "kafka-console-consumer --zookeeper $(terraform output -state=terraform/terraform.tfstate controller.ip):2181 --topic syslog"
```


## Wiping

### Consul

Remove `serial` tags from `ansible/playbooks/{resource,controller}.yml`

```bash
ansible tag_Service_controller -a "bash -c 'sudo systemctl stop consul; sudo rm -rf /var/lib/consul'"
ansible tag_Service_resource -a "bash -c 'sudo systemctl stop consul; sudo rm -rf /var/lib/consul'"
ansible-playbook playbooks/controller.yml  --tags consul
ansible-playbook playbooks/resource.yml  --tags consul
```

### Mesos Slave

To wipe all local data from the mesos slaves and resarts them run:

```bash
ansible-playbook playbooks/resource_clear.yml [-l <limit_to_ip_1>,<limit_to_ip_2>```
```

Add those tags back


## Refreshing

When things don't work, the first thing I would try is re-running the ansible
playbook. This will hard restart nginx if it can't be reloaded.

### NGINX

```bash
ansible-playbook playbooks/controller.yml --tags consul_template
ansible-playbook playbooks/resource.yml --tags consul_template
```

