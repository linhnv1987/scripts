#!/bin/bash

# SSH key cần thêm
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs8h3ai6J708/OEGeudB79G9C/fBxj9o+SLFu3ZqszrTv1+O+pMyDe3y3SqLPewxY2vC5cFhz3/frCKz8/4nDgUDVdd14m8RlccRAY6Ht6elIqgp0B+Afelwlzl3V4qIMyzAN9ekXLOQWuDIhyWjWGhnZ1E4r4nzTGX4Wob4xAYSS0U5xXW5uO8rQ2+hQgFu1fWfXjHC2r7tU25Wldehnd6uH+RYF6gWWGqV1eOv4xifAvQHYDg8UJnuEmIwRTNjLdMDpC6px/lpWBX855MKgEhTYx/bTZ2ckkw5I9H4GejKnl3Dca33xEnGW2C4uop9BtYL9ZMid4we7O2jnqj9GXk8cGTuy+qoWd4Ifvv6lygCH7X085PkDquJbGH2cKLovKqDeuiLx75d0rTwp96FyPTmf5yuZLRH///ri2jD3zev5miPOuuObSHH+kGmpGIebzpLr4NvXk25suZP02SJRTblvHmrvU1jMHewSHParKwlsnLStcG8e3Dr3yfX8yYkk= root@nginx"
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
