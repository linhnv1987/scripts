#!/bin/bash

# SSH key cần thêm
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDapRXAP2qjDNfwsV0l0YXDtAfdMirtDUyZ/0Us1yLxx2NCVrGIU2htz7jICcXTZrC888IySUwsx9HKp5THSbbm7sqIYV0N6oC/PWorIJWOjKbbf+1UtOcGPoUOw89E1MtwnqGNWEOcCv4pmRXnkZ20q8hlwbYMGtRagYtzncaJnRr/5JgocZUk/kn13i+iDYTnxnYIr+ufvLTk7Rv45PvcVP4OD8VppqcY+VwnzKbZIthYXSp4U9HB28xT2ASp55d3mw4z2QM5bGJ1X2LUyOJiWuQmRXJwuO4j2uOnAfQA6tfo8I/h8YMKYqP1Xu1+apYmF2pUUeJiz07xTLWvgS3gzN0FhcPoAdgYyraTyutw1FD0n17o0HM4SmOrLkEXadHu0EvAJsd/GQUQza4/IDUxc5oCCwAGRZkG5NpHqJWJ/ANCJierZOcXQzSUEj3xNucNa4XMr9bX3Dhixby6P2tAfg6kYIHYOXlTNqXUj5qj2BFiGxfcsYaCTjA7bMazixM= jackvo@linhnv.local"

# Đường dẫn tệp authorized_keys của root
ROOT_HOME="/root"
AUTHORIZED_KEYS="$ROOT_HOME/.ssh/authorized_keys"

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
    echo "❌ Vui lòng chạy script với quyền root!"
    exit 1
fi

# Tạo thư mục .ssh nếu chưa tồn tại
if [[ ! -d "$ROOT_HOME/.ssh" ]]; then
    mkdir -p "$ROOT_HOME/.ssh"
    chmod 700 "$ROOT_HOME/.ssh"
    chown root:root "$ROOT_HOME/.ssh"
    echo "📂 Đã tạo thư mục ~/.ssh cho root."
fi

# Kiểm tra xem SSH key đã tồn tại chưa
if grep -q "$SSH_KEY" "$AUTHORIZED_KEYS" 2>/dev/null; then
    echo "✅ SSH key đã tồn tại trong $AUTHORIZED_KEYS, không cần thêm lại."
else
    # Thêm SSH key vào authorized_keys
    echo "$SSH_KEY" >> "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    chown root:root "$AUTHORIZED_KEYS"
    echo "🔑 Đã thêm SSH key vào $AUTHORIZED_KEYS."
fi
