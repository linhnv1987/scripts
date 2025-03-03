#!/bin/bash

# Cấu hình
NEW_PORT=22222  # Đổi thành cổng mong muốn
SSHD_CONFIG="/etc/ssh/sshd_config"

# Yêu cầu chạy với quyền root
if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script với quyền root!"
   exit 1
fi

# Sao lưu file cấu hình trước khi chỉnh sửa (chỉ sao lưu 1 lần nếu chưa có)
BACKUP_FILE="${SSHD_CONFIG}.bak"
if [[ ! -f $BACKUP_FILE ]]; then
    cp $SSHD_CONFIG $BACKUP_FILE
    echo "📦 Đã sao lưu cấu hình gốc: $BACKUP_FILE"
fi

# Kiểm tra xem cổng SSH đã được thay đổi chưa
CURRENT_PORT=$(grep "^Port " $SSHD_CONFIG | awk '{print $2}')
if [[ "$CURRENT_PORT" == "$NEW_PORT" ]]; then
    echo "✅ Cổng SSH đã được cấu hình là $NEW_PORT, không cần thay đổi."
else
    # Cập nhật cổng SSH (nếu chưa đổi)
    sed -i "/^Port /d" $SSHD_CONFIG
    echo "Port $NEW_PORT" >> $SSHD_CONFIG
    echo "🔄 Đã cập nhật cổng SSH thành $NEW_PORT."
fi

# Cấu hình tắt đăng nhập bằng mật khẩu (nếu chưa được thiết lập)
sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication no/g" $SSHD_CONFIG
sed -i "s/^PasswordAuthentication.*/PasswordAuthentication no/g" $SSHD_CONFIG
sed -i "s/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g" $SSHD_CONFIG
sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g" $SSHD_CONFIG
sed -i "s/^#UsePAM.*/UsePAM no/g" $SSHD_CONFIG
sed -i "s/^UsePAM.*/UsePAM no/g" $SSHD_CONFIG
sed -i "s/^#PubkeyAuthentication.*/PubkeyAuthentication yes/g" $SSHD_CONFIG
sed -i "s/^PubkeyAuthentication.*/PubkeyAuthentication yes/g" $SSHD_CONFIG

echo "🔒 Đã đảm bảo chỉ cho phép SSH bằng SSH key."

# Mở cổng mới trên tường lửa (nếu cần)
if command -v ufw &> /dev/null; then
    ufw allow $NEW_PORT/tcp
    ufw reload
    echo "🔥 Đã mở cổng $NEW_PORT trên UFW."
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --add-port=$NEW_PORT/tcp --permanent
    firewall-cmd --reload
    echo "🔥 Đã mở cổng $NEW_PORT trên FirewallD."
fi

# Kiểm tra lỗi cấu hình trước khi restart SSH
if sshd -t; then
    systemctl restart sshd
    echo "✅ Cấu hình SSH đã được cập nhật và dịch vụ SSH đã khởi động lại thành công!"
else
    echo "❌ Lỗi trong file cấu hình SSH! Khôi phục bản sao lưu..."
    cp $BACKUP_FILE $SSHD_CONFIG
    systemctl restart sshd
    echo "🔄 Đã khôi phục cấu hình cũ."
fi
