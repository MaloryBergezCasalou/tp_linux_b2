#!/bin/bash

# malorybergezcasalou
# 13 octobre 2020
# script install nfs

yum install nfs-utils -y
systemctl enable nfs-server.service
systemctl start nfs-server.service
