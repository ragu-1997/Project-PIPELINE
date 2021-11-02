#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

: ${DNS_DOMAIN:=".node.dc1.consul"}

if [ $# -lt 1 ]; then
    echo "Usage: `basename $0` <HOST>"
    echo
    exit 1
fi

if [[ $1 = *"."* ]]; then
    HOST=$1
else
    HOST=$1$DNS_DOMAIN
fi

ssh $HOST
