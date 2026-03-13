#!/bin/bash
set -euxo pipefail

log() {
  echo "[INIT] $1"
}

get_private_ip() {
  local token

  token=$(curl -fsS -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  curl -fsS -H "X-aws-ec2-metadata-token: $${token}" \
    "http://169.254.169.254/latest/meta-data/local-ipv4"
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
  DEBIAN_FRONTEND=noninteractive apt install -y nginx curl vim htop 
}

configure_nginx() {
  local private_ip

  private_ip=$(get_private_ip)

  log "Starting nginx"
  systemctl enable nginx
  systemctl start nginx

cat <<EOF > /var/www/html/index.nginx-debian.html
${html_page_base64}
EOF

  base64 -d /var/www/html/index.nginx-debian.html > /var/www/html/index.nginx-debian.decoded
  mv /var/www/html/index.nginx-debian.decoded /var/www/html/index.nginx-debian.html
  sed -i 's|$${private_ip}|'"$private_ip"'|g' /var/www/html/index.nginx-debian.html

}

main() {
  wait_for_internet
  install_packages
  configure_nginx
}

main
