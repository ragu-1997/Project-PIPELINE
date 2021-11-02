# Checking Service Status's
To check whether the cluster came up, we have to look at a lot of services.

Ansible is also set up to verify some of the pieces are working, by making sure
ports are open and it can send status checks to them. To run these tests:

```bash
cd ansible
ansible-playbook playbooks/all.yml --tags test
```

<!-- use MarkdownTOC package in sublime text to update automatically on save -->
<!-- MarkdownTOC depth=5 autolink=true bracket=round -->

- [Consul](#consul)
  - [UI](#ui)
- [Elasticsearch](#elasticsearch)
- [Kafka](#kafka)
- [Mesos](#mesos)
  - [Marathon](#marathon)
  - [Chronos](#chronos)
- [Zookeeper](#zookeeper)
  - [Exhibitor (UI)](#exhibitor-ui)
- [Elasticache](#elasticache)
  - [Redis](#redis)
- [RDS](#rds)
  - [Postgres](#postgres)
- [Logging](#logging)
  - [Docker Logs to Kafka (`logspout-kafka`)](#docker-logs-to-kafka-logspout-kafka)
- [Microservices](#microservices)
  - [Marathon](#marathon-1)
  - [Registrator](#registrator)
    - [Dangling Containers](#dangling-containers)
  - [Consul Template Internal NGINX](#consul-template-internal-nginx)
  - [Consul Template External NGINX](#consul-template-external-nginx)
  - [External ELB](#external-elb)
  - [Consul Template Frontend NGINX](#consul-template-frontend-nginx)
  - [External ELB](#external-elb-1)
  - [External DNS](#external-dns)
  - [Marathon + Custom Docker Registry](#marathon--custom-docker-registry)

<!-- /MarkdownTOC -->


## Consul

```bash
curl http://$(terraform output -state=terraform/terraform.tfstate controller.ip):8500/v1/catalog/nodes
```

### UI

```bash
open http://$(terraform output -state=terraform/terraform.tfstate controller.ip):8500/ui/
```

## Elasticsearch

** todo
```bash
curl $(terraform output -state=terraform/terraform.tfstate elasticsearch.ip):9200/_cat/health?v
```

## Kafka

It has no API, so we can try getting it's topics and making sure that doesn't crash

```bash
ssh -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate kafka.ip) "kafka-topics --zookeeper $(terraform output -state=terraform/terraform.tfstate controller.ip):2181 --list"
```

Or to create a new topic

```bash
ssh -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate kafka.ip) "kafka-topics --zookeeper $(terraform output -state=terraform/terraform.tfstate controller.ip):2181 --create --topic my_topic_name --partitions 20 --replication-factor 3"
```

## Mesos

```bash
# Master
open http://$(terraform output -state=terraform/terraform.tfstate controller.ip):5050
```

### Marathon

```bash
curl http://$(terraform output -state=terraform/terraform.tfstate controller.ip):8080/v2/info

# GUI
open http://$(terraform output -state=terraform/terraform.tfstate controller.ip):8080
```


### Chronos

```bash
# GUI
open http://$(terraform output -state=terraform/terraform.tfstate controller.ip):4400
```


## Zookeeper


```bash
curl $(terraform output -state=terraform/terraform.tfstate controller.ip):8181/exhibitor/v1/cluster/status
```

### Exhibitor (UI)

```bash
open http://$(terraform output -state=terraform/terraform.tfstate controller.ip):8181/exhibitor/v1/ui/index.html
```

## Elasticache

### Redis

```bash
ssh -t -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate controller.ip) "sudo docker run -it --rm redis sh -c \"exec redis-cli -h $(terraform output -state=terraform/terraform.tfstate redis.address) -p $(terraform output -state=terraform/terraform.tfstate redis.port) -a rootroot info\""
```

## RDS

### Postgres

```bash
ssh -t -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate resource.ip) "sudo docker run -it -e PGPASSWORD=rootroot --rm postgres sh -c \"exec psql -U rootroot -h $(terraform output -state=terraform/terraform.tfstate postgres.address) -l\""
```

## Logging

### Docker Logs to Kafka (`logspout-kafka`)
All docker logs should be sent to Kafka in the `docker-logs` topic.

So first let's bring up a docker container that has some logs:

```bash
ssh -t -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate resource.ip) "sudo docker run --rm hello-world"
```

That should give some output. Now we wanna make sure kafka has this output:

```bash
ssh -i ssh/insecure-deployer centos@$(terraform output -state=terraform/terraform.tfstate kafka.ip) "kafka-console-consumer --zookeeper $(terraform output -state=terraform/terraform.tfstate controller.ip):2181 --topic docker-logs --from-beginning"
```

## Microservices
Finally we wanna test the whole package.

We will be using marathon a lot, so these instructions use
[marathonctl](https://github.com/shoenig/marathonctl) which is nicer than
creating our own bash scripts around marathons API. They assume you have
have installed that first.

Then we have to set our marathon host

```bash
cd marathon
echo marathon.host: http://$(terraform output -state=../terraform/terraform.tfstate controller.ip):8080 > marathonctl.properties
```

All remaining steps assume you are in the `./marathon` directory


Also the `./marathon/bin/address.sh` command requires [jq](http://stedolan.github.io/jq/)
installed.

### Marathon
First let's just test to make sure marathon is working.

So let's launch a container that does nothing and exposes no ports

```bash
marathonctl -c marathonctl.properties  app create apps/dummy-no-ports.json
```

Then check that is loaded and has been deployed

```bash
marathonctl -c marathonctl.properties task list /dummy-no-ports
```

And then we can destroy it

```bash
marathonctl -c marathonctl.properties app destroy dummy-no-ports
```


Now we wanna try one with ports

```bash
marathonctl -c marathonctl.properties app create apps/dummy-one-port.json
marathonctl -c marathonctl.properties task list /dummy-one-port
curl -v $(bin/address.sh dummy-one-port)/
```

And destroy it

```bash
marathonctl -c marathonctl.properties app destroy dummy-one-port
```

### Registrator
OK now lets try launching a container and making sure it gets registered
in consul


```bash
marathonctl -c marathonctl.properties app create apps/birds.json
curl http://$(terraform output -state=../terraform/terraform.tfstate controller.ip):8500/v1/catalog/service/birds
```

#### Dangling Containers

Now lets destroy that app and make sure it isn't still registered.


```bash
marathonctl -c marathonctl.properties app destroy backend-birds
curl http://$(terraform output -state=../terraform/terraform.tfstate controller.ip):8500/v1/catalog/service/birds
```


OK now let's try restarting the host forefully and making sure it doesn't
stick around then:

```bash
marathonctl -c marathonctl.properties app create apps/birds.json
# should exist
curl http://$(terraform output -state=../terraform/terraform.tfstate controller.ip):8500/v1/catalog/service/birds
# reboot that machine
ssh -t -i ../ssh/insecure-deployer centos@$(curl http://$(terraform output -state=../terraform/terraform.tfstate controller.ip):8500/v1/catalog/service/birds | jq -r .[0].Node) "sudo reboot"
marathonctl -c marathonctl.properties app destroy backend-birds
# shouldn't exist
curl http://$(terraform output -state=../terraform/terraform.tfstate controller.ip):8500/v1/catalog/service/birds
```


### Consul Template Internal NGINX
Now lets make sure it actually accessible on each host in NGINX

```bash
marathonctl -c marathonctl.properties app create apps/birds.json
curl http://$(terraform output -state=../terraform/terraform.tfstate resource.ip):8008/birds/
```

Once you see it works, you should destroy it

```bash
marathonctl -c marathonctl.properties app destroy backend-birds
```

### Consul Template External NGINX
If we launch a external service, it should be accessible on the controller
on port `80`.

```bash
marathonctl -c marathonctl.properties app create apps/cats.jangl.com.json
marathonctl -c marathonctl.properties task list /cats.jangl.com
curl -v --resolve cats.jangl.com:80:$(terraform output -state=../terraform/terraform.tfstate controller.ip)  http://cats.jangl.com/
```

Now we can try another domain and make sure it is differentiated

```bash
marathonctl -c marathonctl.properties app create apps/dogs.jangl.com.json
curl --resolve dogs.jangl.com:80:$(terraform output -state=../terraform/terraform.tfstate controller.ip)  http://dogs.jangl.com/
```

### External ELB
Now lets make sure amazons ELB will route toward it

```bash
curl --resolve cats.jangl.com:80:$(dig +short $(terraform output -state=../terraform/terraform.tfstate elb.external.domain) | head -n 1) http://cats.jangl.com/
curl --resolve dogs.jangl.com:80:$(dig +short $(terraform output -state=../terraform/terraform.tfstate elb.external.domain) | head -n 1) http://dogs.jangl.com/
```

They should return different resaults, showing they are coming from different
instances

Now lets delete all of those

```bash
marathonctl -c marathonctl.properties app destroy cats.jangl.com
marathonctl -c marathonctl.properties app destroy dogs.jangl.com
```

### Consul Template Frontend NGINX
If we launch a `jangl-frontend` service, it should be accessible on the controller
on port `81`.

```bash
marathonctl -c marathonctl.properties app create apps/jangl-frontend.json
marathonctl -c marathonctl.properties task list /jangl-frontend
curl -v --resolve some-weird-domain.jangl.com:81:$(terraform output -state=../terraform/terraform.tfstate controller.ip)  http://some-weird-domain.jangl.com:81/
```

### External ELB
Now lets make sure amazons ELB will route toward it

```bash
curl -v --resolve some-weird-domain.jangl.com:80:$(dig +short $(terraform output -state=../terraform/terraform.tfstate elb.frontend.domain) | head -n 1) http://some-weird-domain.jangl.com/
```

### External DNS

Now we should be able to just hit that domain, since we have a `*.jangl.com`
record pointing to that elb.

```bash
curl -v http://some-weird-domain.jangl.com/
```

Now lets delete that

```bash
marathonctl -c marathonctl.properties app destroy jangl-frontend
```

### Marathon + Custom Docker Registry
We should test if the marathon instance can pull an image from our custom
Docker registry.

First let's upload an image to the custom docker repo:

```bash
docker pull saulshanabrook/webserver-debug:0.1
docker tag saulshanabrook/webserver-debug:0.1 docker.jangl.com/saulshanabrook/webserver-debug:0.1
docker push docker.jangl.com/saulshanabrook/webserver-debug:0.1
```

Then we can create a marathon config that uses this image:

```bash
sed -e "s~<image name>~docker.jangl.com/saulshanabrook/webserver-debug:0.1~g" apps/docker-custom-registry.json.tmpl > apps/docker-custom-registry.json
```

Then we can upload this app:

```bash
marathonctl -c marathonctl.properties app create apps/docker-custom-registry.json
```

Make sure it has started:

```bash
marathonctl -c marathonctl.properties task list /docker-custom-registry
```

Then try hitting it:

```bash
curl -v $(bin/address.sh docker-custom-registry)/
```

And then destroy it

```bash
marathonctl -c marathonctl.properties app destroy docker-custom-registry
```
