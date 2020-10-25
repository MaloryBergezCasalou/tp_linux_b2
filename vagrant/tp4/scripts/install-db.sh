yum install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload

echo >> /etc/my.cnf << EOL
[mysqld]
bind-address = 192.168.4.11
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

symbolic-links=0

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

!includedir /etc/my.cnf.d
EOL

