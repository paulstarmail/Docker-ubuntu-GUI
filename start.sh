#!/bin/bash
/opt/TurboVNC/bin/vncserver -kill :1 >/dev/null 2>&1
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
/opt/TurboVNC/bin/vncserver :1 -geometry 1600x900 -depth 24 -localhost no
exec websockify --web=/usr/share/novnc/ 6080 localhost:5901
