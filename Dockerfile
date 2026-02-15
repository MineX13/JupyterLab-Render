FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# System update + packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    libzmq3-dev \
    ca-certificates \
    curl \
    wget \
    nginx \
    tmux \
    neofetch \
    git \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install JupyterLab
RUN python3 -m pip install jupyterlab

# Install ttyd (web terminal)
RUN wget https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
    -O /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# Dark bash + auto neofetch
RUN echo 'export TERM=xterm-256color' >> /root/.bashrc && \
    echo 'neofetch' >> /root/.bashrc

# Remove default nginx config
RUN rm /etc/nginx/sites-enabled/default

# Reverse proxy (single Railway port)
RUN echo 'server {
    listen 8080;

    location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /terminal/ {
        proxy_pass http://127.0.0.1:7681/;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}' > /etc/nginx/sites-enabled/default

# Startup script
RUN echo '#!/bin/bash
ttyd -p 7681 -t theme={"background":"#0d1117","foreground":"#c9d1d9"} bash &
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="" &
nginx -g "daemon off;"
' > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
