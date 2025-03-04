#!/bin/bash

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy với quyền root!"
   exit 1
fi

# Xác định card mạng chính (card có default route)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

# Nếu không tìm thấy card mạng, thoát với lỗi
if [[ -z "$INTERFACE" ]]; then
    echo "Không tìm thấy card mạng! Vui lòng kiểm tra kết nối."
    exit 1
fi

echo "Đã phát hiện card mạng: $INTERFACE"

# Nhập thông tin từ người dùng
read -p "Nhập địa chỉ IP tĩnh (ví dụ: 192.168.1.100): " STATIC_IP
read -p "Nhập subnet mask (định dạng CIDR, ví dụ: 24 cho 255.255.255.0): " NETMASK
read -p "Nhập địa chỉ gateway (ví dụ: 192.168.1.1): " GATEWAY
read -p "Nhập hostname mới cho server: " NEW_HOSTNAME
read -p "Nhập DNS servers (mặc định 8.8.8.8, 8.8.4.4): " DNS

# Nếu không nhập DNS, dùng mặc định
if [[ -z "$DNS" ]]; then
    DNS="8.8.8.8,8.8.4.4"
fi

# Đặt hostname mới
echo "Đang đổi hostname thành: $NEW_HOSTNAME..."
hostnamectl set-hostname "$NEW_HOSTNAME"

# Cập nhật /etc/hosts
echo "Cập nhật /etc/hosts..."
sed -i "/127.0.1.1/c\127.0.1.1 $NEW_HOSTNAME" /etc/hosts

# Xác định file cấu hình Netplan
NETPLAN_FILE=$(ls /etc/netplan/*.yaml | head -n 1)

if [[ -z "$NETPLAN_FILE" ]]; then
    echo "Không tìm thấy file cấu hình Netplan! Hãy kiểm tra lại."
    exit 1
fi

echo "Sử dụng file Netplan: $NETPLAN_FILE"

# Ghi cấu hình mới vào file Netplan
cat <<EOF > $NETPLAN_FILE
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: no
      addresses:
        - $STATIC_IP/$NETMASK
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [$DNS]
EOF

# Áp dụng cấu hình mới
echo "Áp dụng cấu hình mạng..."
netplan apply

echo "✅ Cấu hình hoàn tất! Hostname: $NEW_HOSTNAME | IP: $STATIC_IP | Interface: $INTERFACE | DNS: $DNS"
