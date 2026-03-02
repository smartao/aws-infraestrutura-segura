#!/bin/bash
until ping -c 1 google.com; do
  echo "Waiting for internet..."
  sleep 5
done

apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
HOST=$(hostname)
echo "Pagina $HOST" > /var/www/html/index.nginx-debian.html