#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
HOST=$(hostname)
echo "Pagina $HOST" > /var/www/html/index.nginx-debian.html