#!/bin/sh

set -x

# Update system
yum -y update
yum -y install epel-release
yum -y install cloud-init cloud-utils

# Remove old kernel headers
yum -y install kernel-{firmware,headers,devel}

# Install mainline kernel
#rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
#yum -y --enablerepo=elrepo-kernel install kernel-ml
#yum -y --enablerepo=elrepo-kernel install kernel-ml-{firmware,headers,devel}

#grub2-set-default 0
