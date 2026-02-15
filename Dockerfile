FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Install system packages
# -----------------------------
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

# -----------------------------
# Install JupyterLab
# -----------------------------
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install jupyterlab

# -----------------------------
# Install ttyd (web terminal)
# -----------------------------
RUN wget https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
    -O /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# -----------------------------
# Dark terminal config
# -----------------------------
RUN echo 'export TERM=xterm-256color' >> /root/.bashrc && \
    echo 'neofetch' >> /root/.bashrc

# -----------------------------
# Nginx reverse proxy (ONE PORT)
# -----------------------------
RUN rm /etc/nginx/sites-enabled/default

RUN cat <<EOF > /etc/nginx/sites-enabled/default
server {
    listen 8080;

    location /terminal {
        proxy_pass http://127.0.0.1:7681;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }

    location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

# -----------------------------
# Startup Script
# -----------------------------
RUN cat <<EOF > /start.sh
#!/bin/bash

# Start ttyd terminal (dark theme)
ttyd -p 7681 -t theme='{"background":"#0d1117","foreground":"#c9d1d9"}' bash &

# Start Jupyter
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="" &

# Start nginx (main process)
nginx -g "daemon off;"
EOF

RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
