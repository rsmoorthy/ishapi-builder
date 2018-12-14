#!/bin/bash

echo "$1"

function show_status() {
  sleep 2
  ifconfig wlan0
  iwconfig
  ps auxww | grep wpa_supplicant
  systemctl status dnsmasq
  systemctl status hostapd
}

function hotspot_off() {
  echo "Stopping hotspot and starting normal"
  ip link set dev wlan0 down
  systemctl stop dnsmasq
  systemctl stop hostapd
  ip addr flush wlan0
  ip link set dev wlan0 up
	if [[ -f "/boot/wpa_supplicant.conf" ]]; then
  	wpa_supplicant -B -i wlan0 -c /boot/wpa_supplicant.conf
	else
  	wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant//wpa_supplicant.conf
	fi
  dhcpcd -n wlan0
}

function hotspot_on() {
  echo "Creating hotspot"
  wpa_cli terminate
  ip addr flush wlan0
  ip link set dev wlan0 down
  rm -rf /var/run/wpa_supplicant

  ip addr add 192.168.90.1/24 brd + dev wlan0
  ip link set dev wlan0 up
  
  dhcpcd -k wlan0
  systemctl start dnsmasq
  systemctl start hostapd
  dhcpcd -n wlan0
}

if [[ $1 == "off" ]]; then
  hotspot_off

elif [[ $1 == "status" ]]; then
  show_status 

elif [[ $1 == "on" ]]; then
  hotspot_on

elif [[ $1 == "service" ]]; then

  if [[ ! -f /boot/wificfg.txt ]]; then
     hotspot_on
     exit
  fi

  if grep -E '^hotspot' /boot/wificfg.txt
  then
     hotspot_on
     exit
  fi

  if grep -E '^wifiOrhotspot' /boot/wificfg.txt
  then
     hotspot_off
     sleep 20
     if ! wpa_cli -i wlan0 status | grep 'ip_address' >/dev/null 2>&1
     then
       hotspot_on
     fi
     exit
  fi

  if grep -E '^wifi' /boot/wificfg.txt
  then
     hotspot_off
     exit
  fi


  
fi
