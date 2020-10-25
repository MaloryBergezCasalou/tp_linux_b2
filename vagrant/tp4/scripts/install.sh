#!/bin/bash

# malorybergezcasalou
# 13 octobre 2020
# script install commun pour toutes les vms du tp 4

# install
yum update
yum install vim -y
yum install wget -y
yum install tree -y

# config selinux
setenforce 0
sed -i 's/."SELINUX=enforcing.*/SELINUX=permissive' /etc/selinux/config

# config hosts
cat >> /etc/hosts << EOL
192.168.4.11 gitea.tp4.b2 gitea
192.168.4.12 db.tp4.b2 db
192.168.4.13 nginx.tp4.b2 nginx
192.168.4.14 nfs.tp4.b2 nfs
EOL
