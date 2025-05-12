FROM lscr.io/linuxserver/webtop:ubuntu-openbox

ENV DEBIAN_FRONTEND=noninteractive

# 1) Build-Deps & Runtime für ComicTagger installieren
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3-venv python3-pip python3-pyqt5 \
      unrar-free libffi-dev pkg-config libicu-dev \
      build-essential python3-dev wmctrl && \
    rm -rf /var/lib/apt/lists/*

# 2) Virtualenv anlegen und ComicTagger (mit GUI+CBR) installieren
RUN python3 -m venv /opt/comictagger-venv && \
    /opt/comictagger-venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /opt/comictagger-venv/bin/pip install --no-cache-dir "comictagger[GUI,CBR]"

# 3) Build-Deps wieder entfernen, damit das Image klein bleibt
RUN apt-get purge -y --auto-remove \
      build-essential python3-dev libffi-dev pkg-config libicu-dev && \
    rm -rf /var/lib/apt/lists/*

# 4) ComicTagger direkt aus dem Webtop-Launcher starten
RUN printf '#!/bin/bash\n\
export PATH=/opt/comictagger-venv/bin:$PATH\n\
sleep 2\n\
comictagger &\n\
sleep 2\n\
wmctrl -r "ComicTagger" -b add,fullscreen\n' \
  > /defaults/autostart \
&& chmod +x /defaults/autostart