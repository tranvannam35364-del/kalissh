FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

# 1. Cập nhật hệ thống và cài đặt các công cụ cần thiết
RUN apt-get update && apt-get install -y \
    tmux \
    openssh-server \
    sudo \
    curl \
    wget \
    nano \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /usr/bin/ttyd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && mkdir -p /var/run/sshd

# 3. Đặt mật khẩu cho tài khoản root
RUN echo 'root:root' | chpasswd

RUN printf '#!/bin/bash\n\
# Khởi động dịch vụ SSH chạy ngầm\n\
service ssh start\n\
# Khởi chạy ttyd làm tiến trình chính để giữ container luôn chạy\n\
exec ttyd -W -p 8080 bash\n' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 8080

# Gọi script khi container khởi động
CMD ["/entrypoint.sh"]
