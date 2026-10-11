FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# More retries and longer timeouts for slow or unreliable connections
RUN printf 'Acquire::Retries "10";\nAcquire::http::Timeout "60";\nAcquire::https::Timeout "60";\n' \
      > /etc/apt/apt.conf.d/80-network

# HTTPS needs certificates first: install them over plain HTTP (small download)
RUN apt update && apt install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# From here on, download everything over HTTPS
RUN sed -i 's|http://|https://|g' /etc/apt/sources.list.d/ubuntu.sources

# Install in smaller steps so successful downloads are cached between attempts
RUN apt update && apt install -y --no-install-recommends \
      sudo vim curl dbus-x11 x11-xserver-utils \
      fonts-dejavu-core hicolor-icon-theme adwaita-icon-theme \
    && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install -y --no-install-recommends \
      xfce4 xfce4-terminal \
    && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install -y --no-install-recommends \
      tigervnc-standalone-server tigervnc-common tigervnc-tools xauth \
      novnc websockify \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu 24.04 images already include a user "ubuntu" (UID 1000)
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# Mount point for the host's Projects folder
RUN mkdir -p /home/ubuntu/Projects

# VNC password and desktop startup script
RUN mkdir -p ~/.vnc && \
    echo "changeme" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

COPY --chown=ubuntu:ubuntu start.sh /home/ubuntu/start.sh
RUN chmod +x /home/ubuntu/start.sh

EXPOSE 5901 6080
CMD ["/home/ubuntu/start.sh"]
