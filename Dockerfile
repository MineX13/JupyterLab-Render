FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev build-essential \
    libffi-dev libssl-dev libzmq3-dev \
    nginx apache2-utils curl ca-certificates \
    tmux htop ttyd rclone pciutils \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install jupyterlab flask psutil GPUtil

COPY nginx.conf /etc/nginx/nginx.conf
COPY htpasswd /etc/nginx/htpasswd
COPY start.sh /start.sh
COPY specs.py /specs.py
COPY gpu.py /gpu.py
COPY help.py /help.py
COPY about.py /about.py

RUN chmod +x /start.sh

WORKDIR /app
EXPOSE 8080

CMD ["/start.sh"]
