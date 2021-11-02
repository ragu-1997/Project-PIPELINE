# Provisioning the Cluster

<!-- use MarkdownTOC package in sublime text to update automatically on save -->
<!-- MarkdownTOC depth=5 autolink=true bracket=round -->

- [Creating the Infastructure](#creating-the-infastructure)
    - [Create AMI with Packer](#create-ami-with-packer)
    - [Create AWS infastructure with Terraform](#create-aws-infastructure-with-terraform)
    - [Provision NAT with Ansible](#provision-nat-with-ansible)
    - [Connect to the VPN before provisioning servers in private network](#connect-to-the-vpn-before-provisioning-servers-in-private-network)
    - [Provision Servers with Ansible](#provision-servers-with-ansible)
- [Updating the Infastructure](#updating-the-infastructure)
    - [Terraform](#terraform)
    - [Ansible](#ansible)
        - [Roles](#roles)
        - [Playbooks](#playbooks)
            - [Run Once Roles](#run-once-roles)
        - [Running Arbitrary Commands](#running-arbitrary-commands)
- [Debugging/Tips](#debuggingtips)

<!-- /MarkdownTOC -->


## Creating the Infastructure

Before you can create the infastructure, or use ansible, you have to get the
SSH key. You can find it [here](https://phab.jangl.com/K2).
Save it into the  `./ssh/insecure-deployer` file.

### Create AMI with Packer

```bash
cd packer
export AWS_ACCESS_KEY_ID='AK123'
export AWS_SECRET_ACCESS_KEY='abc123'
packer build centos.json
```

Then overwrite AMI in `terraform/variables.tf`


### Create AWS infastructure with Terraform

Set ssh keys, terraform get required modules, apply terraform. See terraform docs for details. terraform plan is useful to confirm terraform is working without making changes.

```bash
cd terraform
echo 'access_key = "<insert your access key>"
secret_key = "<insert your secret key>"
' > terraform.tfvars
terraform get
terraform apply
```

Note: Sometimes when deploying the elasticache clusters, it will fail to create
the routes afterword saying something like:

```
* Resource 'aws_elasticache_cluster.default' does not have attribute 'cache_nodes.0.address' for variable 'aws_elasticache_cluster.default.cache_nodes.0.address'
```

The solution is just to look on AWS to wait for the elasticache's to actually
deploy properly, then try `terraform apply` again.

([link to github comment](https://github.com/hashicorp/terraform/pull/1965#issuecomment-102223409))


### Provision VPN with Ansible

```bash
cd ansible
export AWS_ACCESS_KEY_ID='AK123'
export AWS_SECRET_ACCESS_KEY='abc123'

# Provision VPN (have to use different ec2.ini file so that ansible uses its public IP)
env EC2_INI_PATH=ec2.public.ini ansible-playbook playbooks/vpn.yml
```

### Connect to the VPN before provisioning servers in private network

In order to access the internal network, you need to VPN
into the NAT. To do this you need some credentials.

Then run:

```bash
export AWS_ACCESS_KEY_ID='AK123'
export AWS_SECRET_ACCESS_KEY='abc123'

bin/ovpn-new-client <COMMONNAME>
bin/ovpn-client-config <COMMONNAME> > <COMMONNAME>.ovpn
```

You can set `<COMMONNAME>` to be anything. You take the `<COMMONNAME>.ovpn` file you get
out and use your favorite VPN client to load it. For example
`openvpn --config <COMMONNAME>.ovpn`

Edit the .ovpn file and replace `redirect-gateway def1` with `route 10.128.0.0 255.255.0.0`
near the bottom of the file.

Sometimes this generation fails. It might be because you run it too quickly
after provisiong the machine. If it does, just try creating a new client
with a different `COMMONAME` and see if that works.


### Provision Servers with Ansible

```bash
cd ansible
export AWS_ACCESS_KEY_ID='AK123'
export AWS_SECRET_ACCESS_KEY='abc123'

# remove ansible cache so it picks up the private IPs instead of the public
# ones
rm -r ~/.ansible/tmp/

ansible-playbook playbooks/site.yml
```

Note by default the `ec2` plugin for Ansible will cache a list of hosts.
You can change this behavior with the `cache_max_age` config in `ec2.ini` or
`ec2.public.ini`.

## Updating the Infastructure
To change the actual provisioning of services or databases use Terraform and
to change what is deployed, use Ansible.

### Terraform

```bash
cd terraform
```

If you run `terraform plan --module-depth=-1` you can see the changes it will
do to bring the infastructure to the specified state. Then you can run
`terraform apply` to execute that change. Be careful with RDS's. If it says
it will do anything to them, take a backup first, because it might have to
recreate them to make the change.

### Ansible

```bash
cd ansible
```


If you look in this folder, you will see two main s.

#### Roles

The `roles` folder contains a bunch of services that can be deployed. The are created
to be orthogonal. If you look inside any of the roles, you might see
a couple of folders. The important one is `tasks`. Inside there you should
find a `main.yml` folder. This describes all the logic ansible will perform.

The other important folders are `files` and `templates`. Those are used if
inside the tasks we used `template` or `copy` command. The difference is
the `template` command (and files) are formatted through jinja2 first. This
allows us to make them dynamic.

#### Playbooks

The other folder is `playbooks`. You most likely don't need to worry about
the folder in there, but just the `.yml` files. Each represents one
group of hosts and the set of actions to apply on them. So each playbook
is a group of hosts. If you want to run all the roles on those hosts,
use the `ansible-playbook` command. For example, to run all the roles on the
`kafka` machines run `ansible-playbook playbooks/kafka.yml`.

The roles are designed to be idempotent, so there should be no harm in
re-running the roles at any time. It isn't perfect, so it might restart
a service, even if the config wasn't changed. Luckily, ansible supports
rolling updates, which are enabled for all playbooks. This means when you
execute a playbook, it will only execute on a subset of hosts at first,
and if it fails it will stop. This means that distributed consensus driven
protocals like zookeeper and consul wont lose consus when doing updates.

If you wanna do a full deploy and make sure everything is up to date,
you can run `ansible-playbook playbooks/all.yml`. If you just
want to run all the HTTP tests use `ansible-playbook playbooks/all.yml --tags test`

This is an example of tags, which allows another way of selecting what roles
to run. If you look at the `playbooks/resource.yml` file, you will notice
that it contains a bunch of roles, since a lot of things are running on the
resource node. You will also notice that they have tags associated with them.

So to only update the nginx server, run
`ansible-playbook playbooks/resource.yml --tags consul_template_nginx`

##### Run Once Roles
The `playbooks/run_once.yml` is a bit different. All the roles in that playbook
are meant to be run on only one host, it doesn't matter which host it is.
They build docker images and deploy on marathon.

#### Running Arbitrary Commands

You can also execute arbitrary commands on a set of machines with
the `ansible` command. For example:

```bash
ansible tag_Service_resource -a "sudo docker ps"
```

## Debugging/Tips
sometimes mesos/marathon stop working right. One way to solve is to wipe them.

```bash
cd ansible
foreman run ansible tag_Service_controller -a 'sudo systemctl stop marathon'
foreman run ansible tag_Service_controller -a 'sudo systemctl stop mesos-master'
foreman run ansible tag_Service_resource -a 'sudo systemctl stop mesos-slave'
foreman run ansible tag_Service_resource -a 'sudo systemctl stop marathon'
cd ../terraform
curl -X DELETE $(terraform output controller.ip):8181/exhibitor/v1/explorer/znode/mesos -v
curl -X DELETE $(terraform output controller.ip):8181/exhibitor/v1/explorer/znode/marathon -v
cd ../ansible
ansible-playbook playbooks/all.yml --tags mesos
```
