#!/bin/bash
set -euxo pipefail

log() {
  echo "[INIT] $1"
}

wait_for_internet() {
  until ping -c 1 aws.amazon.com; do
    log "Waiting for internet..."
    sleep 5
  done
}

install_packages() {
  log "Updating system"
  apt update -y

  log "Installing packages"
  DEBIAN_FRONTEND=noninteractive apt install -y curl vim htop neofetch tcpdump nmap iotop lynx
}

configure_bastion() {
  log "Configuring bastion host"

  install -m 0755 /dev/stdin /etc/update-motd.d/99-bastion <<'EOF'
#!/usr/bin/env bash

HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)
DATE=$(date)
ENVIRONMENT=${ENVIRONMENT:-dev}
INSTANCE_ID=$(ec2metadata --instance-id)

cat <<MSG
##################################################
 BASTION HOST

 Instance ID: $INSTANCE_ID
 Hostname   : $HOSTNAME
 IP Address : $IP
 Environment: $ENVIRONMENT
 Uptime     : $UPTIME
 Date       : $DATE

##################################################
SECURITY NOTICE

 This system is restricted to authorized users.
 All actions may be monitored and audited.

##################################################
MSG
EOF
}

main() {
  wait_for_internet
  install_packages
  configure_bastion
}

main