FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------
# Install system packages
# --------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    build-essential libffi-dev libssl-dev libzmq3-dev \
    ca-certificates curl wget nginx git tmux neofetch \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------
# Install JupyterLab
# --------------------------------
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install jupyterlab

# --------------------------------
# Bash enhancements
# --------------------------------
RUN echo 'export TERM=xterm-256color' >> /root/.bashrc && \
    echo 'neofetch' >> /root/.bashrc

# --------------------------------
# Configure nginx
# --------------------------------
RUN rm /etc/nginx/sites-enabled/default
RUN cat <<EOF > /etc/nginx/sites-enabled/default
server {
    listen 8080;

    # Stable health check endpoint
    location = /health {
        access_log off;
        return 200 "OK";
        add_header Content-Type text/plain;
    }

    # Jupyter
    location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

# --------------------------------
# Start script
# --------------------------------
RUN cat <<EOF > /start.sh
#!/bin/bash

# Start Jupyter
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token='' &

# Start nginx (foreground)
nginx -g "daemon off;"
EOF

RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
