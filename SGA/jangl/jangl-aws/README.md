# Jangle on AWS

Refer to other docs:

* [**PROVISIONING.md**](PROVISIONING.md): Creating and updating the base
  infastructure.
* [**TESTING.md**](TESTING.md): Verifying that all the infastructure is
  performing correctly .
* [**DEPLOYING_APPS.md**](DEPLOYING_APPS.md): Deploying and updating
  apps in Mesos.
* [**DEBUGGING.md**](DEBUGGING.md): Figuring out what is happening and how
  to fix it

## Tools
We use **[Packer](https://www.packer.io)** to create the base AMI.

We use **[Terraform](https://www.terraform.io/)** to create AWS
infastructure.

Because we are waiting on [this PR to enable redis multi AZ support](https://github.com/hashicorp/terraform/pull/2945) you
have to install Terraform [from my fork](https://github.com/saulshanabrook/terraform)
for now.

Then we use Ansible to provision machines. We won't create/scale AWS via Ansible,
just use it to [auto-find right machines](http://docs.ansible.com/guide_aws.html#tags-and-groups-and-variables)
and update code on them. This is true for all machines besides the NAT, which we
provision directly in Terraform. (`pip install 'ansible==1.9.*'`)

You also have to install the `boto` library (`pip install boto`) so that we
can find the machines from EC2.

## Design Questions
### Why not just use Ansible for everything?
Terraform will update resources in place, instead of creating/destroying.
It also provides a `terraform plan` command that shows what it will do before
it executes.

Terraform also has support for IAM, which ansible doesn't.

#### Resources
1. http://www.thoughtworks.com/insights/blog/choosing-right-tool-provision-aws-infrastructure
2. https://groups.google.com/forum/#!msg/terraform-tool/6Fxnl_bejX4/w6kSgseN_TYJ
