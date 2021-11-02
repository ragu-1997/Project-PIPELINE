#!/usr/bin/env bash
#fix socat-consul down
#always check after machine reboot
sudo systemctl start socat-consul

#fix nginx-consul
#always check after machine reboot
sudo systemctl start nginx-consul

#fix pgbouncer
sudo yum -y remove pgbouncer
sudo yum -y install pgbouncer
sudo mv /etc/pgbouncer/pgbouncer.ini.rpmsave /etc/pgbouncer/pgbouncer.ini
sudo systemctl enable pgbouncer
sudo systemctl start pgbouncer

#free up disk space
sudo rm -f /var/log/messages-*
sudo truncate -s 0 /var/log/pgbouncer.log

#fix mesos-agent
#after above... first try...
#sudo systemctl restart mesos-agent
#then
consul leave
sudo pkill -USR1 mesos-slave
sudo systemctl stop mesos-agent
sudo systemctl disable mesos-agent