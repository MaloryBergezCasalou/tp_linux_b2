# TP1 Malory BERGEZ-CASALOU

## 0. Prérequis

- partitionnement

  ajouter un deuxième disque de 5Go à la machine

Machine 1

```bash
[user@node1 ~]$ lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0    5G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    4G  0 part
  ├─centos-root 253:0    0  3.5G  0 lvm  /
  └─centos-swap 253:1    0  512M  0 lvm  [SWAP]
sdb               8:16   0    5G  0 disk
sr0              11:0    1 1024M  0 rom
```

Machine 2

```bash
clone de machine 1
```

partitionner le nouveau disque avec LVM

Machine 1

```bash
[user@node1 ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[user@node1 ~]$ sudo pvs
  PV         VG     Fmt  Attr PSize  PFree
  /dev/sda2  centos lvm2 a--  <4.00g    0
  /dev/sdb          lvm2 ---   5.00g 5.00g
```

Machine 2

```bash
clone de machine 1
```

  deux partitions, une de 2Go, une de 3Go
  la partition de 2Go sera montée sur /srv/data1
  la partition de 3Go sera montée sur /srv/data2

Machine 1

```bash
[user@node1 ~]$ sudo -i
[sudo] password for user:
[root@node1 ~]# vgcreate svr /dev/sdb
  Volume group "svr" successfully created
[root@node1 ~]# lvcreate -n data1 -L 2g svr
  Logical volume "data1" created.
[root@node1 ~]# lvcreate -n data2 -L 3g svr
  Logical volume "data2" created.
[root@node1 ~]# logout
[user@node1 ~]$ sudo vgrename srv svr
  /dev/svr: already exists in filesystem
[user@node1 ~]$ sudo vgrename svr srv
  Volume group "svr" successfully renamed to "srv"

[user@node1 ~]$ lvdisplay
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lvm/lvmetad.socket: access failed: Permission denied
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  /dev/mapper/control: open failed: Permission denied
  Failure to communicate with kernel device-mapper driver.
  Incompatible libdevmapper 1.02.164-RHEL7 (2019-08-27) and kernel driver (unknown version).
[user@node1 ~]$ sudo !!
sudo lvdisplay
[sudo] password for user:
  --- Logical volume ---
  LV Path                /dev/centos/swap
  LV Name                swap
  VG Name                centos
  LV UUID                RqURIj-pvze-H0mQ-fIY7-xden-ubG1-ixcZpe
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-09-23 15:22:08 +0200
  LV Status              available
  # open                 2
  LV Size                512.00 MiB
  Current LE             128
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/centos/root
  LV Name                root
  VG Name                centos
  LV UUID                wD0v1h-l2Cd-0NZi-pd3H-JlAQ-p1oF-oqlTCO
  LV Write Access        read/write
  LV Creation host, time localhost, 2020-09-23 15:22:08 +0200
  LV Status              available
  # open                 1
  LV Size                <3.50 GiB
  Current LE             895
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/srv/data1
  LV Name                data1
  VG Name                srv
  LV UUID                lFSOzy-YlYi-Hioo-9jWL-fjuH-8erf-F0eCw6
  LV Write Access        read/write
  LV Creation host, time node1.tp1.b2, 2020-09-23 17:20:00 +0200
  LV Status              available
  # open                 0
  LV Size                2.00 GiB
  Current LE             512
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/srv/data2
  LV Name                data2
  VG Name                srv
  LV UUID                hyTMUD-Hb83-KOIa-ooPH-RW2r-qLBM-6bKNZq
  LV Write Access        read/write
  LV Creation host, time node1.tp1.b2, 2020-09-23 17:20:05 +0200
  LV Status              available
  # open                 0
  LV Size                3.00 GiB
  Current LE             768
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:3

  [user@node1 ~]$ sudo mkfs -t ext4 /dev/srv/data1
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131072 inodes, 524288 blocks
26214 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=536870912
16 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

[user@node1 ~]$ sudo mkdir /srv/site1
[user@node1 ~]$ sudo mkdir /srv/site2
[user@node1 ~]$ sudo mount /dev/srv/data1 /srv/site1
[user@node1 ~]$ mount /dev/srv/data1 /srv/site1
mount: only root can do that
[user@node1 ~]$ sudo mount /dev/srv/data1 /srv/site1
[user@node1 ~]$ sudo mount /dev/srv/data2 /srv/site2
[user@node1 ~]$ mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime,seclabel)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
devtmpfs on /dev type devtmpfs (rw,nosuid,seclabel,size=237552k,nr_inodes=59388,mode=755)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,seclabel)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,seclabel,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,nodev,seclabel,mode=755)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,seclabel,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd)
pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,devices)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,pids)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,cpuset)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,perf_event)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,hugetlb)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,cpuacct,cpu)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,net_prio,net_cls)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,blkio)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,freezer)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,seclabel,memory)
configfs on /sys/kernel/config type configfs (rw,relatime)
/dev/mapper/centos-root on / type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
selinuxfs on /sys/fs/selinux type selinuxfs (rw,relatime)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=32,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=12277)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,seclabel)
mqueue on /dev/mqueue type mqueue (rw,relatime,seclabel)
debugfs on /sys/kernel/debug type debugfs (rw,relatime)
/dev/sda1 on /boot type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,seclabel,size=49872k,mode=700,uid=1000,gid=1000)
/dev/mapper/srv-data1 on /srv/site1 type ext4 (rw,relatime,seclabel,data=ordered)
/dev/mapper/srv-data2 on /srv/site2 type ext4 (rw,relatime,seclabel,data=ordered)

[user@node1 ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                 232M     0  232M   0% /dev
tmpfs                    244M     0  244M   0% /dev/shm
tmpfs                    244M  4.6M  239M   2% /run
tmpfs                    244M     0  244M   0% /sys/fs/cgroup
/dev/mapper/centos-root  3.5G  1.5G  2.1G  41% /
/dev/sda1               1014M  167M  848M  17% /boot
tmpfs                     49M     0   49M   0% /run/user/1000
/dev/mapper/srv-data1    2.0G  6.0M  1.8G   1% /srv/site1
/dev/mapper/srv-data2    2.9G  9.0M  2.8G   1% /srv/site2

```

Machine 2

```bash
clone de machine 1
```

  les partitions doivent être montées automatiquement au démarrage (fichier /etc/fstab)

Machine 1

```bash
[user@node1 ~]$ sudo vim /etc/fstab
[sudo] password for user:
[user@node1 ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Wed Sep 23 15:22:10 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=6ac52145-d787-4b1e-81bf-68d3c40dd054 /boot                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0
/dev/srv/data1 /srv/site1 ext4 defaults 0 0
/dev/srv/data2 /srv/site2 ext4 defaults 0 0

[user@node1 ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
swap                     : ignored
/srv/site1               : already mounted
/srv/site2               : already mounted
```

Machine 2

```bash
clone de machine 1
```

- un accès internet

  carte réseau dédiée

Machine 1

```bash
[user@node1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:8e:ce:db brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
       valid_lft 85937sec preferred_lft 85937sec
    inet6 fe80::9ab0:31a7:2c4b:b0b6/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:3a:bb:17 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.11/24 brd 192.168.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe3a:bb17/64 scope link
       valid_lft forever preferred_lft f

[user@node1 ~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

Machine 2

```bash
[user@node2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:87:45:6b brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
       valid_lft 86381sec preferred_lft 86381sec
    inet6 fe80::9ab0:31a7:2c4b:b0b6/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:ce:34:79 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.12/24 brd 192.168.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fece:3479/64 scope link
       valid_lft forever preferred_lft forever

[user@node2 ~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

  route par défaut

Machine 1

```bash
[user@node1 ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.11    node1.tp1.b2
192.168.1.12    node2.tp1.b2
```

Machine 2

```bash
[user@node2 ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.11    node1.tp1.b2
192.168.1.12    node2.tp1.b2
```

  un accès à un réseau local (les deux machines peuvent se ping)

Machine 1

```bash
[user@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (192.168.1.12) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=1 ttl=64 time=0.671 ms
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=2 ttl=64 time=0.296 ms
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=3 ttl=64 time=0.327 ms
^C
--- node2.tp1.b2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.296/0.431/0.671/0.170 ms
```

Machine 2

```bash
[user@node2 ~]$ ping node1.tp1.b2
PING node1.tp1.b2 (192.168.1.11) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=1 ttl=64 time=0.342 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=2 ttl=64 time=0.329 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=3 ttl=64 time=0.354 ms
^C
--- node1.tp1.b2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.329/0.341/0.354/0.023 ms
```

  route locale

Machine 1

```bash
[user@node1 ~]$ ip n s
192.168.1.12 dev enp0s8 lladdr 08:00:27:ce:34:79 STALE
192.168.1.10 dev enp0s8 lladdr 0a:00:27:00:00:1c DELAY
10.0.2.2 dev enp0s3 lladdr 52:54:00:12:35:02 STALE
```

Machine 2

```bash
[user@node2 ~]$ ip n s
192.168.1.10 dev enp0s8 lladdr 0a:00:27:00:00:1c DELAY
192.168.1.11 dev enp0s8 lladdr 08:00:27:3a:bb:17 STALE
10.0.2.2 dev enp0s3 lladdr 52:54:00:12:35:02 STALE
```

- les machines doivent avoir un nom

en root vi /etc/hostname

Machine 1

```bash
[user@node1 ~]$ hostname
node1.tp1.b2
```

Machine 2

```bash
[user@node2 ~]$ hostname
node2.tp1.b2
```

fichier /etc/hosts

Machine 1

```bash
[user@node1 ~]$ sudo vim /etc/hosts
[user@node1 ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.11    node1.tp1.b2
192.168.1.12    node2.tp1.b2
```

Machine 2

```bash
clone de machine 1
```

- un utilisateur administrateur est créé sur les deux machines (il peut exécuter des commandes sudo en tant que root)

création d'un user

Machine 1

```bash
[root@node1 ~]# useradd user
```

Machine 2

```bash
clone de machine 1
```

modification de la conf sudo

Machine 1

```bash
[root@node1 ~]# visudo
```

Machine 2

```bash
clone de machine 1
```

- vous n'utilisez QUE ssh pour administrer les machines

Machine 1

```bash
PS C:\Users\Malory BC> ssh user@192.168.1.11
user@192.168.1.11's password:
Last login: Thu Sep 24 14:52:34 2020 from 192.168.1.10
Last login: Thu Sep 24 14:52:34 2020 from 192.168.1.10
```

Machine 2

```bash
PS C:\Users\Malory BC> ssh user@192.168.1.12
user@192.168.1.12's password:
Last login: Thu Sep 24 14:58:20 2020 from 192.168.1.10
Last login: Thu Sep 24 14:58:20 2020 from 192.168.1.10
```

- le pare-feu est configuré pour bloquer toutes les connexions exceptées celles qui sont nécessaires

commande firewall-cmd ou iptables

Machine 1

```bash
[user@node1 ~]$ firewall-cmd --permanent --zone=public --add-service=http
Authorization failed.
    Make sure polkit agent is running or run the application as superuser.
[user@node1 ~]$ sudo !!
sudo firewall-cmd --permanent --zone=public --add-service=http
[sudo] password for user:
success
```

Machine 2

```bash
rien à faire
```

## I. Setup serveur Web

Machine 1

install de epel-release

```bash
[user@node1 ~]$ sudo yum install -y epel-release

[...]

Installed:
  epel-release.noarch 0:7-11

Complete!
```

install de nginx

```bash
[user@node1 ~]$ sudo yum install -y nginx
[...]
Complete!
```

create user 'web' + conf sudo avec 'visudo'

```bash
[user@node1 ~]$ sudo useradd web
[sudo] password for user:
[user@node1 ~]$ sudo passwd web
Changing password for user web.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
```

on change les droits

```bash
[user@node1 ~]$ sudo chown web /srv/site1
[sudo] password for user:
[user@node1 ~]$ sudo chown web /srv/site2
[user@node1 ~]$ root
-bash: root: command not found
[user@node1 ~]$ ls /srv/site1 -la
total 20
drwxr-xr-x. 3 web  root  4096 Sep 24 14:09 .
drwxr-xr-x. 4 root root    32 Sep 23 17:49 ..
drwx------. 2 root root 16384 Sep 24 14:09 lost+found

[user@node1 ~]$ chmod 400 /srv/site1
chmod: changing permissions of ‘/srv/site1’: Operation not permitted
[user@node1 ~]$ sudo !!
sudo chmod 400 /srv/site1
[user@node1 ~]$ sudo chmod 400 /srv/site2
[sudo] password for user:
```

les sites doivent être servis en HTTPS sur le port 443 et en HTTP sur le port 80

```bash
[user@node1 ~]$ sudo firewall-cmd --zone=public --add-service=http --permanent
success
[user@node1 ~]$ sudo firewall-cmd --zone=public --add-service=https --permanent
success
[user@node1 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user@node1 ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[user@node1 ~]$ sudo firewall-cmd --reload
success
[user@node1 ~]$ sudo firewall-cmd --list-all
[sudo] password for user: 
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources: 
  services: dhcpv6-client http https ssh
  ports: 80/tcp 443/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

prouver que node2 peut joindre les deux sites

```bash

```
