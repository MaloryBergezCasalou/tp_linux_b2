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