#!/bin/bash

# Cấu hình
NEW_PORT=22222  # Đổi thành cổng mong muốn
SSHD_CONFIG="/etc/ssh/sshd_config"

# Yêu cầu chạy với quyền root
if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script với quyền root!"
   exit 1
fi

# Cập nhật cổng SSH
sed -i "s/^#Port 22/Port $NEW_PORT/g" $SSHD_CONFIG
sed -i "s/^Port 22/Port $NEW_PORT/g" $SSHD_CONFIG

# Tắt đăng nhập bằng mật khẩu
sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/g" $SSHD_CONFIG
sed -i "s/^PasswordAuthentication yes/PasswordAuthentication no/g" $SSHD_CONFIG

# Kiểm tra và mở cổng mới trên tường lửa (nếu sử dụng UFW hoặc FirewallD)
if command -v ufw &> /dev/null; then
    ufw allow $NEW_PORT/tcp
    ufw reload
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --add-port=$NEW_PORT/tcp --permanent
    firewall-cmd --reload
fi

# Khởi động lại SSH service
systemctl restart sshd

echo "Cấu hình SSH đã được cập nhật!"
echo "Cổng mới: $NEW_PORT"
echo "Chỉ cho phép đăng nhập bằng SSH key."
