#!/bin/bash
#malorybergezcasalou
#13 octobre 2020

#install gitea
wget -O gitea https://dl.gitea.io/gitea/1.12.5/gitea-1.12.5-linux-amd64
chmod +x gitea
useradd git -m
# config de gitea.service dans ../systemd/gitea.service

