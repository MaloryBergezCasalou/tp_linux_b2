# TP3 Malory BERGEZ-CASALOU 

## 0 PRÉREQUIS
[prerequis](vagarnt/tp3/prerequis)

## 1
### 1.intro
- cli

-afficher le nombre de services systemd dispos sur la machine
```bash
systemctl list-units --type=service | wc -l
```

-afficher le nombre de services systemd actifs et en cours d'exécution ("running") sur la machine
```bash
systemctl -t service --all | grep running | wc -l
```

-afficher le nombre de services systemd qui ont échoué ("failed") ou qui sont inactifs ("exited") sur la machine
```bash
systemctl -t service --all | grep -E 'inactive|failed' | wc -l
```

-afficher la liste des services systemd qui démarrent automatiquement au boot ("enabled")
```bash
 systemctl list-unit-files --type=service | grep enabled | wc -l
```

### 2.analyse d'un service

```bash
[vagrant@localhost ~]$ sudo systemctl cat # /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target

```
ExecStart:localisation de nginx, l'endroit depuis il est lancé

ExecStartPre:commandes executés avant ExecStart

PIDFile:Un fichier pid est un fichier contenant le numéro d'identification du processus (pid) stocké dans un emplacement bien défini du système de fichiers, permettant ainsi à d'autres programmes de trouver le pid d'un script en cours d'exécution

Type:set le process au demarrage du service

ExecReload:commandes à executer pour le reload du service

Description: description

After:configure l'ordre des dependances entre les unités

-Listez tous les services qui contiennent la ligne WantedBy=multi-user.target

rien n'a été installé donc rien n'est disponible pour tous les users

### 3. Création d'un service

#### A. serveur web

je cree un user et modifie ses droits avec 'sudo visudo'
```bash
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
web     ALL=(ALL)       NOPASSWD:ALL
```

on cree un fichier servertp.service dans /etc/systemd/system/ et on met dedans :

```bash
[vagrant@node1 ~]$ sudo systemctl cat servertp
# /etc/systemd/system/servertp.service
[Unit]
Description=server web tp3
After=network.target
Requires=firewalld.service

[Service]
Type=simple
Environment="PORT=8080"
User=web
ExecStartPre=/usr/bin/sudo /usr/bin/firewall-cmd --add-port=${PORT}/tcp
ExecStart=/usr/bin/sudo /usr/bin/python3 -m http.server ${PORT}
ExecReload=/bin/kill -s HUP $MAINPID
ExecStopPost=/usr/bin/sudo /usr/bin/firewall-cmd --remove-port=${PORT}/tcp

[Install]
WantedBy = multi-user.target

```

je lance le service avec ```sudo systemctl start servertp.service```
```bash
[malory@x260 vagrant-tp3]$ curl 192.168.3.11:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="swapfile">swapfile</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>

```


script de backup
```bash
#!/bin/bash
# malorybergezcasalou
# 30/09/2020
# Script de backup avec une limite de 7 backups

target_dir="${1}"
target_path="$(echo "${target_dir%/}" | awk -F "/" 'NF>1{print $NF}')"

date="$(date +%Y%m%d_%H%M%S)"
backup_name="${target_path}_${date}"
backup_dir="/opt/backup"
backup_path="${backup_dir}/${target_path}/${backup_name}.tar.gz"

backup_useruid="1003"
max_backup_number=7

if [[ $UID -ne ${backup_useruid} ]]
then
    echo "Ce script doit être éxecuté avec l'utilisateur backup" >&2
    exit 1
fi

if [[ ! -d "${target_dir}" ]]
then
    echo "Le dossier spécifié n'existe pas !" >&2
    exit 1
fi

backup_folder ()
{
    if [[ ! -d "${backup_dir}/${target_path}" ]]
    then
        mkdir "${backup_dir}/${target_path}"
    fi

    tar -czvf \
        ${backup_path} \
        ${target_dir} \
        1> /dev/null \
        2> /dev/null

    if [[ $(echo $?) -ne 0 ]]
    then
        echo "Une erreur est survenue lors de la compréssion" >&2
        exit 1
    else
        echo "La compréssion à réussi dans ${backup_dir}/${target_path}" >&1
    fi
}

delete_outdated_backup ()
{
    if [[ $(ls "${backup_dir}/${target_path}" | wc -l) -gt max_backup_number ]]
    then
        oldest_file=$(ls -t "${backup_dir}/${target_path}" | tail -1)
        rm -rf "${backup_dir}/${target_path}/${oldest_file}"
    fi
}

backup_folder
delete_outdated_backup
```

#### B. sauvegarde

voir vagrantfile + scripts mais backup de fonctionne pas 

```bash
[vagrant@node1 ~]$ systemd-analyze plot | grep -G '[^(]..ms'
<text x="20" y="50">Startup finished in 427ms (kernel) + 831ms (initrd) + 8.040s (userspace) = 9.299s</text><text x="20" y="30">CentOS Linux 7 (Core) node1.tp3.b2 (Linux 3.10.0-1127.19.1.el7.x86_64 #1 SMP Tue Aug 25 17:23:54 UTC 2020) x86-64 kvm</text><g transform="translate(20.000,100)">
  <text class="left" x="163.754" y="234.000">rhel-domainname.service (101ms)</text>
  <text class="left" x="165.986" y="314.000">systemd-vconsole-setup.service (417ms)</text>
  <text class="left" x="171.720" y="534.000">dev-sda1.device (841ms)</text>
  <text class="left" x="178.098" y="554.000">swapfile.swap (926ms)</text>
  <text class="left" x="178.290" y="574.000">systemd-udev-trigger.service (237ms)</text>
  <text class="left" x="178.383" y="594.000">rhel-readonly.service (181ms)</text>
  <text class="left" x="178.573" y="614.000">systemd-tmpfiles-setup-dev.service (161ms)</text>
  <text class="left" x="194.806" y="654.000">systemd-udevd.service (121ms)</text>
  <text class="left" x="197.314" y="774.000">systemd-tmpfiles-setup.service (137ms)</text>
  <text class="left" x="211.291" y="794.000">var-lib-nfs-rpc_pipefs.mount (409ms)</text>
  <text class="left" x="211.392" y="814.000">auditd.service (625ms)</text>
  <text class="left" x="280.162" y="1294.000">rpcbind.service (276ms)</text>
  <text class="left" x="283.647" y="1354.000">chronyd.service (338ms)</text>
  <text class="left" x="284.734" y="1394.000">systemd-logind.service (323ms)</text>
  <text class="left" x="307.285" y="1434.000">polkit.service (255ms)</text>
  <text class="left" x="307.396" y="1454.000">gssproxy.service (140ms)</text>
  <text class="left" x="307.483" y="1474.000">rhel-dmesg.service (134ms)</text>
  <text class="left" x="333.406" y="1674.000">firewalld.service (964ms)</text>
  <text class="right" x="735.171" y="1834.000">network.service (518ms)</text>
  <text class="right" x="788.003" y="1934.000">sshd.service (139ms)</text>

```

les trois services les plsu lents:
firewalld.service (964ms), 
swapfile.swap (926ms), 
dev-sda1.device (841ms)

changement de l'heure

pour voir mon fuzeau horaire je fais 
```timedatectl```, je suis en utc +0000

pour changer mon fuzeau horaire je fais 
```timedatectl set-timezone "Europe/Paris"```

```bash
[vagrant@node1 ~]$ timedatectl
timedatectl
      Local time: Fri 2020-10-09 23:25:56 CEST
  Universal time: Fri 2020-10-09 21:25:56 UTC
        RTC time: Fri 2020-10-09 21:25:54
       Time zone: Europe/Paris (CEST, +0200)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  Sun 2020-03-29 01:59:59 CET
                  Sun 2020-03-29 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  Sun 2020-10-25 02:59:59 CEST
                  Sun 2020-10-25 02:00:00 CET

```
comme tu peux le voir je fini mon tp au dernier moment :)

pour mon hostname je fais un ```hostnamectl```

```bash
[vagrant@node1 ~]$ hostnamectl
   Static hostname: node1.tp3.b2
         Icon name: computer-vm
           Chassis: vm
        Machine ID: af62670c7b810640a39ef28be3901bce
           Boot ID: 687bdab6f6df4a3c8e06773753bc8b10
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.19.1.el7.x86_64
      Architecture: x86-64

```
 mon hostname est celui defini dans le vagantfile mais je peux le modifier avec ```sudo hostnamectl set-hostname <nouvo-nom>```

