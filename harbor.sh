#!/bin/bash

# Cấu hình biến
HARBOR_VERSION="2.10.0"
HARBOR_INSTALL_DIR="/opt/harbor"
HARBOR_HOSTNAME="192.168.0.25"  # Đặt IP của bạn
HARBOR_ADMIN_PASSWORD="Harbor@123"

# Cập nhật hệ thống
echo "Cập nhật hệ thống..."
sudo apt update -y && sudo apt upgrade -y  # Dành cho Ubuntu/Debian
# sudo yum update -y  # Dành cho CentOS/RHEL

# Cài đặt Docker
echo "Cài đặt Docker..."
if ! command -v docker &> /dev/null
then
    curl -fsSL https://get.docker.com | sh
    sudo systemctl enable --now docker
fi

# Cài đặt Docker Compose
echo "Cài đặt Docker Compose..."
if ! command -v docker-compose &> /dev/null
then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Tải và cài đặt Harbor
echo "Tải và cài đặt Harbor..."
mkdir -p "$HARBOR_INSTALL_DIR"
cd "$HARBOR_INSTALL_DIR"
curl -L https://github.com/goharbor/harbor/releases/download/v$HARBOR_VERSION/harbor-offline-installer-v$HARBOR_VERSION.tgz -o harbor.tgz
tar -xzf harbor.tgz && cd harbor

# Cấu hình Harbor với HTTP & IP cụ thể
echo "Cấu hình Harbor với IP $HARBOR_HOSTNAME..."
cat > harbor.yml <<EOF
hostname: $HARBOR_HOSTNAME
http:
  port: 8080
harbor_admin_password: $HARBOR_ADMIN_PASSWORD
database:
  password: "HarborDB@123"
data_volume: /data
log:
  level: info
# Vô hiệu hóa HTTPS
https:
  enabled: false
EOF

# Cài đặt và khởi động Harbor
echo "Cài đặt và khởi động Harbor..."
./prepare
sudo ./install.sh

# Kiểm tra trạng thái container
echo "Harbor đã được cài đặt thành công! Kiểm tra trạng thái:"
docker ps

echo "Bạn có thể truy cập Harbor tại: http://$HARBOR_HOSTNAME:8080"
echo "Admin Username: admin"
echo "Admin Password: $HARBOR_ADMIN_PASSWORD"
