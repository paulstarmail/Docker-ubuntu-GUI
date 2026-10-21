FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# Install in smaller steps so successful downloads are cached between attempts
RUN apt update && apt install -y --no-install-recommends \
      sudo vim curl dbus-x11 x11-xserver-utils \
      fonts-dejavu-core hicolor-icon-theme adwaita-icon-theme xubuntu-desktop \
      tigervnc-standalone-server tigervnc-common tigervnc-tools xauth novnc websockify

# Ubuntu 24.04 images already include a user "ubuntu" (UID 1000)
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# VNC password and desktop startup script
RUN mkdir -p ~/.vnc && \
    echo "changeme" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

COPY --chown=ubuntu:ubuntu start.sh /home/ubuntu/start.sh
RUN chmod +x /home/ubuntu/start.sh

EXPOSE 5901 6080
CMD ["/home/ubuntu/start.sh"]
