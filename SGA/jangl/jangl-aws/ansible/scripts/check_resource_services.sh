#!/usr/bin/env bash
# check_resource_services.sh
export STAT_MESOS="mesos-slave: $(sudo systemctl status mesos-slave | grep Active | awk 'NR==1{print$2}')"
export STAT_NGINX_CONSUL="nginx-consul: $(sudo systemctl status nginx-consul | grep Active | awk 'NR==1{print$2}')"
export STAT_PGBOUNCER="pgbouncer: $(sudo systemctl status pgbouncer | grep Active | awk 'NR==1{print$2}')"
export STAT_REXRAY="rexray: $(sudo systemctl status rexray | grep Active | awk 'NR==1{print$2}')"
export STAT_DISK="sys_vol_disk_usage: $(df -h / | awk 'NR==2{print$5}')"

echo "*** Jangl Resource Service System Status ***"
echo $STAT_MESOS
echo $STAT_NGINX_CONSUL
echo $STAT_PGBOUNCER
echo $STAT_REXRAY
echo $STAT_DISK
