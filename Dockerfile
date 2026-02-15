FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------
# Install system packages
# ------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    build-essential libffi-dev libssl-dev libzmq3-dev \
    ca-certificates curl wget nginx git tmux neofetch \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------
# Install JupyterLab
# ------------------------------------------------
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install jupyterlab

# ------------------------------------------------
# Improve bash experience
# ------------------------------------------------
RUN echo 'export TERM=xterm-256color' >> /root/.bashrc && \
    echo 'neofetch' >> /root/.bashrc

# ------------------------------------------------
# Configure nginx (single public port 8080)
# ------------------------------------------------
RUN rm -f /etc/nginx/sites-enabled/default

RUN cat <<EOF > /etc/nginx/sites-enabled/default
server {
    listen 8080;
    server_name _;

    # Health endpoint (supports GET + HEAD)
    location = /health {
        default_type text/plain;
        return 200 "OK";
    }

    # Handle Railway HEAD health checks on /
    location = / {
        if (\$request_method = HEAD) {
            return 200;
        }

        proxy_pass http://127.0.0.1:8888;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Proxy everything else to Jupyter
    location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# ------------------------------------------------
# Start script
# ------------------------------------------------
RUN cat <<EOF > /start.sh
#!/bin/bash

# Start Jupyter
jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --ServerApp.token='' \
  --ServerApp.allow_origin='*' \
  --ServerApp.base_url='/' &

# Start nginx in foreground
nginx -g "daemon off;"
EOF

RUN chmod +x /start.sh

# Railway public port
EXPOSE 8080

CMD ["/start.sh"]
