#!/bin/bash

# SSH key cần thêm
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOQwUF9JZ83d/hOOTVZuKm7AR3BO5PMULDfuv1N+AMho8yahjH9mG6+8JeuIB8SODxeB1TpGy70Jb1PQneixX3o4mak97SRF0KsA9x6bfSEe1goCmG7tIWsYvr2mMcamrhVBk8jvXd4/H/Ze9FkkR8BztfLTJPOJDKatEt+LmK0pnsZs931CeJwnPH4LB6dfy/gIFmuHdi2+C/vvQMLc/e/xseI2/ofvvznpYKz5fgLSXY8VKmFj0bkR16Qi4m7NyPpGG/5H+pPDWsaDLPW0N+DZGs0bHDtlOuSq0ryEXsS8zyzQSTaZ8/DYM+eIapRRtkt9S7/CxlSIe7ZtAjI6wn37k7Xf6qrPtcX1Q9/xcOhzpaQEwlOkVK3Jve69sGQg2M27JffocoXWJqW/AKv3rIlS22PNrWJJ1w8usMmNao0tMiyj/BXtkv9bzWh2fAcHmjApBJllaLIWQie6fpSsGaG0/yGhSYpF6jgxnxYZSGcn6bOSGDOWM9oh6VRC7+si8= admin@linhnv"

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
