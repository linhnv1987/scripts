#!/bin/bash

# SSH key cần thêm
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2aUoHiAm68zFvkX9n+ntoOxNnpM7mI8kb8MnNscFF6BhopHFtTuOw/rT4Y4L+DovXLaI/Qt6JRHQtwmXo+X8BeEKuh4+iQfxJN87nnMxA26Y7l/pA8u7n4oWFw5Q9OEvRnXDd+jcp/lzuMz9aho8zTsvHX4fsLOsar2ShrXptIdw5maTDkhQwhIuuFETYDBaIgO+9c4hCtF/4Gx8Uu4UragBGu2J2O9R9TG10Ogxs69vIxesxGVoZrANqr9jMjTZqNBjm8F97W6lMzo+UH6Rm6C3D+y0h/aCEBUyAV3sKvyrVJUmGycHtOYxAvi8c2pEw9McH4pTh7U/4Gi28B3WjJtSALKJrY4cpIIZQXj36eSTEx6chvF7C2UYDZGc5yvSzF+Thl4TUlOc6xo/azcIPdhMbDM0jBa0lFa6WZyu6xmVCJrhpZ9RzUbkgl7w3UjBzKEk+jhLPWYEAZGwo/BjTFUUrPPXHeDWcMaSteWndZ01S56R6v4VAfn2jQXPF518= root@nginxproxy"

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
