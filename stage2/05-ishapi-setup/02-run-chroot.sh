#!/bin/bash -e

usermod -a -G audio,video,input,dialout,plugdev,netdev,users,cdrom,tty "pi"
chown -R pi.pi /home/pi/.ssh

dpkg -l | grep kodi
uname -a

ls -l /etc/systemd/system/
systemctl daemon-reload
systemctl enable kodi.service
systemctl disable ssh.service

systemctl enable dnsmasq.service
systemctl enable hostapd.service
systemctl enable autohotspot.service
systemctl enable piserver.service
systemctl disable dispmanx.service

if ! grep -E '^interface wlan0' /etc/dhcpcd.conf
then
  echo "interface wlan0" >> /etc/dhcpcd.conf
  echo "  nohook wpa_supplicant" >> /etc/dhcpcd.conf
fi
sudo sed /etc/default/hostapd -i -e 's|^#DAEMON_CONF=""|DAEMON_CONF=/etc/hostapd/hostapd.conf|'

# For usbmount to work
sudo sed /lib/systemd/system/systemd-udevd.service -i -e 's|MountFlags=slave|MountFlags=shared|'

plymouth-set-default-theme text

# Disable various services
systemctl disable bluetooth || true
systemctl disable hciuart || true
systemctl disable getty@tty1 || true
systemctl disable rsyslog || true
systemctl disable systemd-journal-flush || true
systemctl disable nfs-client nss-lookup || true
systemctl disable nfs-client.target || true
systemctl disable nss-lookup.target || true
systemctl disable remote-fs-pre.target || true
systemctl disable remote-fs.target || true
systemctl disable cron || true
systemctl disable polkit.service || true

# Disable this - so that /boot/wpa_supplicant.conf is not moved over
systemctl disable raspberrypi-net-mods.service

# Dont wait for network during booting
rm -f /etc/systemd/system/dhcpcd.service.d/wait.conf

# Create directory
mkdir -p /storage/ishamedia || true
chown -R pi.pi /storage

mkdir -p /mnt/Ishamedia || true

#
## Delete unneeded packages
#apt purge -y apt-transport-https apt-listchanges lua5.1 luajit diff-utils aptitude-common aptitude
#apt autoremove -y

# Delete unneeded packages
for pkg in apt-transport-https apt-listchanges man-db aptitude-common aptitude gcc-4.6-base gcc-4.7-base gcc-4.8-base gcc-4.9-base gcc-5-base info dpkg-dev libfreetype6-dev libgcc-6-dev libmnl-dev libpng-dev libraspberrypi-dev manpages-dev zlib1g-dev build-essential
do
  echo "\n******************Checking package $pkg--------------------------\n"
  if dpkg -l $pkg
  then
	apt purge -y $pkg
  fi
done
apt autoremove -y
apt-get clean
dpkg -l

# Removing unneeded files
rm -rf /usr/include
rm -rf /usr/lib/cmake
rm -rf /usr/lib/pkgconfig
rm -rf /usr/man
rm -rf /usr/share/aclocal
rm -rf /usr/share/bash-completion
rm -rf /usr/share/doc
rm -rf /usr/share/gtk-doc
rm -rf /usr/share/info
rm -rf /usr/share/locale
rm -rf /usr/share/man
rm -rf /usr/share/pkgconfig
rm -rf /usr/share/zsh
rm -rf /usr/var
