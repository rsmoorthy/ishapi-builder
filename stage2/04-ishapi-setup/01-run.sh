#!/bin/bash

install -m 755 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
install -m 755 files/hostapd.conf	"${ROOTFS_DIR}/etc/hostapd/hostapd.conf"
install -m 755 files/dnsmasq.conf	"${ROOTFS_DIR}/etc/dnsmasq.conf"

install -m 755 files/autohotspot	"${ROOTFS_DIR}/usr/bin/"
install -m 644 files/autohotspot.service	"${ROOTFS_DIR}/etc/systemd/system/"

install -m 644 files/kodi.service	"${ROOTFS_DIR}/etc/systemd/system/"

# Boot file
install -m 644 files/cmdline.txt "${ROOTFS_DIR}/boot/"

install -d -m 700 "${ROOTFS_DIR}/home/pi/.ssh"
install -m 600 files/ssh_keys.txt "${ROOTFS_DIR}/home/pi/.ssh/authorized_keys"

# rc.local file
install -m 755 files/rc.local "${ROOTFS_DIR}/etc/"

# Splash image
install -m 644 files/kodi_splash.png     "${ROOTFS_DIR}/usr/share/kodi/media/Splash.png"

# SSH files
install -m 700 files/get_sshkeys.py     "${ROOTFS_DIR}/usr/bin/get_sshkeys.py"
install -m 644 files/sshd_config        "${ROOTFS_DIR}/etc/ssh/sshd_config"

# Pi Web server
install -d -m 755 "${ROOTFS_DIR}/opt/ishapi"
install -m 755 files/web.py     "${ROOTFS_DIR}/opt/ishapi/"
install -m 755 files/ishapi/piserver/vols.bash     "${ROOTFS_DIR}/opt/ishapi/"
install -m 755 files/ishapi/piserver/wificfg.py     "${ROOTFS_DIR}/opt/ishapi/"
install -m 755 files/ishapi/piserver/AESCipher.py     "${ROOTFS_DIR}/opt/ishapi/AESCipher.py"
install -m 755 files/ishapi/piserver/mycerts.py     "${ROOTFS_DIR}/opt/ishapi/mycerts.py"
install -m 644 files/ishapi/piserver/piserver.service	"${ROOTFS_DIR}/etc/systemd/system/"

# Poweroff and reboot (that uses sudo to do actual ones)
install -m 755 files/reboot     "${ROOTFS_DIR}/usr/local/bin/reboot"
install -m 755 files/poweroff     "${ROOTFS_DIR}/usr/local/bin/poweroff"

# Install all kodi files
cp -a files/ishapi/kodi-usrshare/addons/* "${ROOTFS_DIR}/usr/share/kodi/addons/"
chown -R root.root "${ROOTFS_DIR}/usr/share/kodi/addons/"
cp -a files/ishapi/kodi-usrshare/system/* "${ROOTFS_DIR}/usr/share/kodi/system/"
cp -a files/ishapi/kodi-usrshare/media/* "${ROOTFS_DIR}/usr/share/kodi/media/"

# Dispmanx VNC
install -m 755 files/dispmanx_vncserver "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/dispmanx.service "${ROOTFS_DIR}/etc/systemd/system/"


