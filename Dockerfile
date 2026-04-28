FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------
# Install system packages
# ------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    build-essential libffi-dev libssl-dev libzmq3-dev \
    ca-certificates curl wget nginx git tmux neofetch \
    ttyd \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------
# Install JupyterLab
# ------------------------------------------------
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install jupyterlab

# ------------------------------------------------
# Create /captcha folder (shared workspace)
# ------------------------------------------------
RUN mkdir -p /captcha

# ------------------------------------------------
# Improve bash experience
# ------------------------------------------------
RUN echo 'export TERM=xterm-256color' >> /root/.bashrc && \
    echo 'neofetch' >> /root/.bashrc && \
    echo 'cd /captcha' >> /root/.bashrc

# ------------------------------------------------
# Configure nginx
# ------------------------------------------------
RUN rm -f /etc/nginx/sites-enabled/default
RUN cat <<'EOF' > /etc/nginx/sites-enabled/default
server {
    listen 8080;
    server_name _;

    # ── UptimeRobot / Railway health checks ──────────────────────────
    location = /health {
        default_type text/plain;
        return 200 "OK";
    }

    # Pingable endpoint for UptimeRobot (GET + HEAD on /cap/ping)
    location = /cap/ping {
        default_type text/plain;
        return 200 "OK";
    }

    # HEAD on / for Railway
    location = / {
        if ($request_method = HEAD) {
            return 200;
        }
        proxy_pass http://127.0.0.1:8888;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # ── /cap → ttyd web terminal ──────────────────────────────────────
    location /cap {
        proxy_pass http://127.0.0.1:7681;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 43200s;
    }

    # ── Everything else → JupyterLab ─────────────────────────────────
    location / {
        proxy_pass http://127.0.0.1:8888;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# ------------------------------------------------
# Start script
# ------------------------------------------------
RUN cat <<'EOF' > /start.sh
#!/bin/bash

# Start JupyterLab (rooted at /captcha so it opens there by default)
jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
  --ServerApp.token='' \
  --ServerApp.allow_origin='*' \
  --ServerApp.base_url='/' \
  --ServerApp.root_dir='/captcha' &

# Start ttyd web terminal at /cap, working directory /captcha
ttyd \
  --port 7681 \
  --base-path /cap \
  --writable \
  bash &

# Start nginx in foreground
nginx -g "daemon off;"
EOF

RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
