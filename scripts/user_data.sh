#!/bin/bash
set -euxo pipefail

log() {
  echo "[INIT] $1"
}

wait_for_internet() {
  until ping -c 1 google.com; do
    log "Waiting for internet..."
    sleep 5
  done
}

install_packages() {
  log "Updating system"
  apt update -y

  log "Installing packages"
  DEBIAN_FRONTEND=noninteractive apt install -y nginx curl vim htop neofetch
}

configure_nginx() {
  log "Starting nginx"
  systemctl enable nginx
  systemctl start nginx

  log "Creating custom page"
  echo "Pagina $(hostname)" > /var/www/html/index.nginx-debian.html
}

main() {
  wait_for_internet
  install_packages
  configure_nginx
}

main