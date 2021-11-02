#!/bin/bash
set -e
DIR="$(cd $(dirname "$0")/.. && pwd)"

source $DIR/envs/testing-env

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

cp $DIR/envs/testing.tfvars $DIR/terraform/terraform.tfvars
cp $DIR/envs/testing-env $DIR/packer/.env
cp $DIR/envs/testing-key $DIR/ssh/aws-key
cp $DIR/envs/testing-key.pub $DIR/ssh/aws-key.pub
chmod 600 $DIR/ssh/aws-key

rm -rf ~/.ansible/tmp/
if [[ -f $DIR/terraform/terraform.tfstate ]]; then
  mv $DIR/terraform/terraform.tfstate $DIR/terraform/terraform.tfstate.backup
fi
cp -f $DIR/terraform/terraform.tfstate.testing $DIR/terraform/terraform.tfstate

head -3 $DIR/terraform/terraform.tfvars
PS1="(testing) \h:\W \u\$ " bash

cp -f $DIR/terraform/terraform.tfstate $DIR/terraform/terraform.tfstate.testing
cp -f $DIR/terraform/terraform.tfvars $DIR/envs/testing.tfvars

rm -f $DIR/terraform/terraform.tfstate \
      $DIR/terraform/terraform.tfvars \
      $DIR/packer/.env \
      $DIR/ssh/aws-key \
      $DIR/ssh/aws-key.pub
