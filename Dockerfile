FROM nvidia/cuda:12.6.3-runtime-ubuntu24.04
ENV DEBIAN_FRONTEND=noninteractive

# Expose the GPU driver capabilities to the container's internal display server
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all,graphics,utility

# Define official package versions for GPU-accelerated VNC
ARG VGL_VERSION=3.1.1
ARG TVNC_VERSION=3.1.1

# Install baseline dependencies and desktop environment, excluding TigerVNC
RUN apt update && apt install -y --no-install-recommends \
      sudo vim curl dbus-x11 x11-xserver-utils wget ca-certificates \
      fonts-dejavu-core hicolor-icon-theme adwaita-icon-theme xubuntu-desktop \
      xauth novnc websockify libxv1 libxtst6 libglu1-mesa

# Download and install official TurboVNC and VirtualGL binaries for hardware acceleration
RUN wget https://sourceforge.net{VGL_VERSION}/virtualgl_${VGL_VERSION}_amd64.deb && \
    wget https://sourceforge.net{TVNC_VERSION}/turbovnc_${TVNC_VERSION}_amd64.deb && \
    dpkg -i virtualgl_${VGL_VERSION}_amd64.deb && \
    dpkg -i turbovnc_${TVNC_VERSION}_amd64.deb && \
    rm virtualgl_${VGL_VERSION}_amd64.deb turbovnc_${TVNC_VERSION}_amd64.deb

# Ubuntu base configuration continues below...
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# TurboVNC specific setup (Uses turbovnc's path structure)
RUN mkdir -p ~/.vnc && \
    echo "changeme" | /opt/TurboVNC/bin/vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

COPY --chown=ubuntu:ubuntu start.sh /home/ubuntu/start.sh
RUN chmod +x /home/ubuntu/start.sh

EXPOSE 5901 6080
CMD ["/home/ubuntu/start.sh"]
