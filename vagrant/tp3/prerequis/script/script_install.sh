#!/bin/bash
# malorybergezcasalou
# 5 octobre 2020
# script update, install vim, nginx and tree

yum update -y

yum install vim -y
yum install epel-release -y
yum install nginx -y
yum install tree -y

# je desactive selinux à la main
