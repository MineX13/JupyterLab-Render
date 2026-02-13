FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Install minimal packages
RUN apt update && apt install -y --no-install-recommends \
    tigervnc-standalone-server \
    novnc \
    websockify \
    xterm \
    dbus-x11 \
    x11-xserver-utils \
    openssl \
    fonts-dejavu-core \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Create VNC startup file for full dark terminal
RUN mkdir -p /root/.vnc && \
    echo '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec xterm \
  -fa "DejaVu Sans Mono" \
  -fs 14 \
  -bg black \
  -fg white \
  -fullscreen \
  -bc' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

# Railway requires app to bind to $PORT
CMD bash -c "\
    vncserver -localhost no -SecurityTypes None -geometry 1280x800 --I-KNOW-THIS-IS-INSECURE && \
    openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
    websockify --web=/usr/share/novnc/ --cert=self.pem 0.0.0.0:$PORT localhost:5901 \
"
