#!/bin/bash
set -euo pipefail

export APP_LANG=${APP_LANG:-en}

##### ##### ##### ##### ##### ### ###
# Installation script configuration #
##### ##### ##### ##### ##### ##### ###
export DEBIAN_FRONTEND=noninteractive #
OPENNDS_VER=v8.0.0		      #
pushd $(dirname $0)		      #
CONFDIR=$(dirname $PWD)/configs       #
HTDOCS=$(dirname $PWD)/htdocs
popd                                  #
##### ##### ##### ##### ##### ##### ###

function prerequisites_install () {
echo iptables-persistent iptables-persistent/autosave_v4 boolean false | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | sudo debconf-set-selections
sudo apt-get install -y --no-install-recommends sudo git vim nano build-essential dh-systemd net-tools iptables-persistent iw wireless-tools ebtables crda
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy || true
sudo systemctl disable --now unattended-upgrades.service # disable system upgrade

}

function hostapd_install () {

sudo apt-get install -y --no-install-recommends hostapd
sudo install -T $CONFDIR/default-hostapd.conf   /etc/default/hostapd
if [ ! -z "${WIFI_SSID:-}" ] ; then
	sed -i "s|FreeWiFi|$WIFI_SSID|g"   /etc/default/hostapd
fi
sudo install -T $CONFDIR/hostapd.$APP_LANG.conf      /etc/hostapd/hostapd.conf
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

}

function dnsmasq_install () {

sudo apt-get install -y --no-install-recommends dnsmasq
sudo install -T $CONFDIR/dnsmasq.conf /etc/dnsmasq.conf

}

function network_configure () {

##### iptables #####
sudo chattr -aui /etc/iptables
sudo install -T $CONFDIR/iptables-rules.v4	/etc/iptables/rules.v4
# systemd-networkd #
sudo install -T $CONFDIR/wlan0.network		/etc/systemd/network/wlan0.network
##### netplan ######
sudo rm -f /etc/netplan/*.yml /etc/netplan/*.yaml
sudo install -T $CONFDIR/netplan.yaml		/etc/netplan/netplan.yaml
#################
#sudo install -T $CONFDIR/interfaces		/etc/network/interfaces
sudo sed -i 's|^127\.0\.0\.1|127.0.0.1 localhost ubuntu|g' /etc/hosts
sudo rm /etc/resolv.conf && echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf
sudo systemctl disable --now systemd-resolved
echo | sudo tee /etc/iptables/rules.v6
sudo chattr +aui /etc/iptables
sudo tee /etc/sysctl.d/99-ip_forward.conf <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6=1
EOF

}

function opennds_install () {

wget https://github.com/openNDS/openNDS/archive/$OPENNDS_VER.tar.gz -O- | tar xz
wget https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-latest.tar.gz -O- | tar xz
mv libmicrohttpd-*/ libmicrohttpd
mv openNDS-*/ opennds
pushd libmicrohttpd/
./configure
make
sudo rm -f /usr/local/lib/libmicrohttpd*
sudo make install
sudo rm -f /etc/ld.so.cache
sudo ldconfig -v
popd
pushd opennds/
make
sudo make install
KEY=$( head /dev/urandom | sha256sum | head -c64 )
sudo install -T $CONFDIR/opennds.conf	/etc/opennds/opennds.conf
echo "faskey $KEY" >> /etc/opennds/opennds.conf
sudo install -T $CONFDIR/login.sh	/usr/lib/opennds/login.sh
sed -i "s|^key=.*|key=$KEY|g"		/usr/lib/opennds/login.sh
sudo rsync -av --delete $HTDOCS/	/etc/opennds/htdocs/
sudo ln -s /etc/opennds/htdocs/form.$APP_LANG.html /etc/opennds/htdocs/form.html
sudo ln -s /etc/opennds/htdocs/postauth.$APP_LANG.html /etc/opennds/htdocs/postauth.html
sudo install -T $CONFDIR/gform.sh	/etc/opennds/gform.sh
sudo systemctl daemon-reload
sudo systemctl enable --now iptables
sudo systemctl enable --now opennds
sudo systemctl restart hostapd

}

prerequisites_install
network_configure
dnsmasq_install
hostapd_install
opennds_install

echo "Modify Google form configuration by running : sudo nano /etc/opennds/gform.sh"
echo "Press any key to reboot, CTRL+C to exit"
read -s -n1 && sudo reboot || exit 0
