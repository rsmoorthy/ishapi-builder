apt purge -y --allow-change-held-packages kodi kodi-bin kodi-data || true
dpkg -i /tmp/kodi_17.6-3~stretch_all.deb /tmp/kodi-bin_17.6-2~stretch_armhf.deb || true
apt-mark hold kodi=2:17.6-3~stretch
apt-mark hold kodi-bin=2:17.6-2~stretch
apt install -f -y
rm /tmp/kodi_17.6-3~stretch_all.deb /tmp/kodi-bin_17.6-2~stretch_armhf.deb
