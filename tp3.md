# TP3 Malory BERGEZ-CASALOU

## 0 PRÉREQUIS
[prerequis](vagarnt/tp3/prerequis)

## 1
### 1.intro
- cli

-afficher le nombre de services systemd dispos sur la machine
```bash
systemctl list-unit-files --type=service | tail -1 | cut -d " " -f 1
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

After:dependances du service

-Listez tous les services qui contiennent la ligne WantedBy=multi-user.target

rien n'a été installé donc rien n'est disponible pour tous les users

### 3. Création d'un service
on cree un fichier servertp.service dans /etc/systemd/system/ et on met dedans :

```bash
[vagrant@localhost system]$ cat servertp.service 
[Unit]  
Description=server b2 tp3
[Service]
Type=simple
User=nginx
Environment="PORT=80"
ExecStartPre=+/usr/bin/firewalld --add-port=${PORT}/tcp
ExecStart=/usr/bin/python3 -m http.server ${PORT}
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=+/usr/bin/firewalld --remove-port=${PORT}/tcp

[Install]
WantedBy=multi-user.target
```
