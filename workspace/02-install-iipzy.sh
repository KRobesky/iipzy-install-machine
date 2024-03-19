#!/bin/bash

declare -r -i EXIT_ERROR=1
declare -r -i EXIT_OK=0
declare -r	  SERVICE_PATH="/etc/init.d/"

##--declare	gitEmail=''
##--declare	gitPassword=''
##--declare	gitRepo=''
##--declare	gitRoot=''
##--declare	gitUserName=''
declare dcPassword=''

function ProcessArguments # see below for the options
{
	local gitEmailNext=false
	local gitPassNext=false
	local gitRepoNext=false
	local gitRootNext=false
	local gitUserNext=false
	local dcPasswordNext=false
	while [ $# -gt 0 ]; do
		[ "$1" = '-gitemail' ] && gitEmailNext=true && shift && continue
		[ "$1" = '-gitpass' ] && gitPassNext=true && shift && continue
		[ "$1" = '-gitrepo' ] && gitRepoNext=true && shift && continue
		[ "$1" = '-gitroot' ] && gitRootNext=true && shift && continue
		[ "$1" = '-gituser' ] && gitUserNext=true && shift && continue
		[ "$1" = '-dcpass' ] && dcPasswordNext=true && shift && continue
		$gitEmailNext && gitEmail="$1" && gitEmailNext=false && shift && continue
		$gitPassNext && gitPassword="$1" && gitPassNext=false && shift && continue
		$gitRepoNext && gitRepo="$1" && gitRepoNext=false && shift && continue
		$gitRootNext && gitRoot="$1" && gitRootNext=false && shift && continue
		$gitUserNext && gitUserName="$1" && gitUserNext=false && shift && continue
		$dcPasswordNext && dcPassword="$1" && dcPasswordNext=false && shift && continue
	done

	##--if [ "$gitEmail" = '' ]; then
	##--	echo "-gitemail is missing"
	##--	exit $EXIT_ERROR
	##--fi

	##--if [ "$gitPassword" = '' ]; then
	##--	echo "-gitpass is missing"
	##--	exit $EXIT_ERROR
	##--fi

	##--if [ "$gitRepo" = '' ]; then
	##--	echo "-gitrepo is missing"
	##--	exit $EXIT_ERROR
	##--fi

	##--if [ "$gitRoot" = '' ]; then
	##--	echo "-gitroot is missing"
	##--	exit $EXIT_ERROR
	##--fi

	##--if [ "$gitUserName" = '' ]; then
	##--	echo "-gituser is missing"
	##--	exit $EXIT_ERROR
	##--fi

	if [ "$dcPassword" = '' ]; then
		echo "-dcpass is missing"
		exit $EXIT_ERROR
	fi

	##--echo "-gitemail: $gitEmail"
	##--echo "-gitpass:  $gitPassword"
	##--echo "-gitrepo:  $gitRepo"
	##--echo "-gitroot:  $gitRoot"
	##--echo "-gituser:  $gitUserName"
	echo "-dcpass:  $dcPassword"
}

function WaitForTimeSet
{
	echo "waiting for time to be set"

	EPOCH="UTC 1970"
	while [[ `date` == *"$EPOCH"* ]]; do
		echo -n '.'
		sleep 1
	done
}

#====================================================
# Starts here.
#
# We assume we're starting after 01-install-os
#====================================================

ProcessArguments "$@"

WaitForTimeSet

opkg update

##--echo ====================================
##--echo Installing python3
##--echo ====================================
##--
##--opkg install python3

##--echo ====================================
##--echo Set timezone UTC
##--echo ====================================
##--# 
##--timedatectl set-timezone UTC
# 
echo ====================================
echo Create iipzy folders
echo ====================================
#
mkdir /home
mkdir /home/pi
mkdir /home/pi/iipzy-core-a
mkdir /home/pi/iipzy-encrypt-a
mkdir /home/pi/iipzy-sentinel-web-a
mkdir /home/pi/iipzy-sentinel-web-client-proxy-a
mkdir /home/pi/iipzy-sentinel-admin-a
mkdir /home/pi/iipzy-updater-a
mkdir /home/pi/iipzy-tc-a
cd /home/pi/iipzy-core-a
# 
##--echo ====================================
##--echo Install unzip
##--echo ====================================
##--#
##--sudo apt install unzip
##--# 
##--echo ====================================
##--echo Install node.js
##--echo ====================================
##--# Install Node.js on Raspberry Pi	- from https://www.w3schools.com/nodejs/nodejs_raspberrypi.asp
##--# 
##--# 	With the Raspberry Pi properly set up, login in via SSH, and update your Raspberry Pi system packages to their latest versions.
##--# 
##--# 	Update your system package list:
##--# 
##--sudo apt-get update -y
##--# 
##--# 	Upgrade all your installed packages to their latest version:
##--# 
##--sudo apt-get dist-upgrade -y
##--# 
##--# 		Doing this regularly will keep your Raspberry Pi installation up to date.
##--# 
##--# 	To download and install newest version of Node.js, use the following command:
##--# 
##--curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
##--# 
##--# 	Now install it by running:
##--# 
##--sudo apt-get install -y nodejs
##--# 
##--# 	Check that the installation was successful, and the version number of Node.js with:
##--# 
echo ====================================
echo "node version: $(node -v)"
echo ====================================
# 
npm config set package-lock false
npm config set loglevel warn
# 
echo ====================================
echo Install static web server
echo ====================================
#
npm install -g serve 2> /dev/null
#
echo ====================================
echo Create directories.
echo ====================================
#
# 
# 	- create /var/log/iipzy so that directory is writable by non-root
# 
#mkdir /var/log/iipzy
##--chown pi:pi /var/log/iipzy
# 
# 	- create /etc/iipzy
# 
mkdir /etc/iipzy
chmod 777 /etc/iipzy
echo  '{' > /etc/iipzy/iipzy.json
if [ ! -z "$dcPassword" ]; then
	echo  "  \"dcPassword\":\"$dcPassword\"," >> /etc/iipzy/iipzy.json
fi
echo  '  "serverAddress":"iipzy.net"' >> /etc/iipzy/iipzy.json
echo  '}' >> /etc/iipzy/iipzy.json
#
#
echo ====================================
echo Install iipzy-encrypt
echo ====================================
# 
cd /home/pi/iipzy-encrypt-a
git clone -q "http://github.com/KRobesky/iipzy-encrypt.git"
# 
# install iipzy-encrypt stuff
# 
cd /home/pi/iipzy-encrypt-a/iipzy-encrypt
npm i 2> /dev/null
#
echo ====================================
echo Install iipzy-core
echo ====================================
#
cd /home/pi/iipzy-core-a
git clone -q "http://github.com/KRobesky/iipzy-shared.git"
git clone -q "http://github.com/KRobesky/iipzy-core.git"
# 
# install iipzy-core stuff
# 
cd /home/pi/iipzy-core-a
# 
cd /home/pi/iipzy-core-a/iipzy-shared
npm i 2> /dev/null
cd /home/pi/iipzy-core-a/iipzy-core
npm i 2> /dev/null
#
echo ====================================
echo Install iipzy-sentinel-web
echo ====================================
# 
cd /home/pi/iipzy-sentinel-web-a
git clone -q "http://github.com/KRobesky/iipzy-sentinel-web.git"
#
echo ====================================
echo Install iipzy-sentinel-web-client-proxy
echo ====================================
# 
cd /home/pi/iipzy-sentinel-web-client-proxy-a
git clone -q "http://github.com/KRobesky/iipzy-shared.git"
git clone -q "http://github.com/KRobesky/iipzy-sentinel-web-client-proxy.git"
# 
# install  iipzy-sentinel-web-client-proxy stuff
# 
cd /home/pi/iipzy-sentinel-web-client-proxy-a/iipzy-shared
npm i 2> /dev/null
cd /home/pi/iipzy-sentinel-web-client-proxy-a/iipzy-sentinel-web-client-proxy
npm i 2> /dev/null

echo ====================================
echo Install iipzy-sentinel-admin
echo ====================================
# 
cd /home/pi/iipzy-sentinel-admin-a
git clone -q "http://github.com/KRobesky/iipzy-shared.git"
git clone -q "http://github.com/KRobesky/iipzy-sentinel-admin.git"
# 
# install  iipzy-sentinel-admin stuff
# 
cd /home/pi/iipzy-sentinel-admin-a/iipzy-shared
npm i 2> /dev/null
cd /home/pi/iipzy-sentinel-admin-a/iipzy-sentinel-admin
npm i 2> /dev/null
# 
# 	- test
# 
# 	npm start
# 
echo ====================================
echo Install iipzy-updater
echo ====================================
# 
cd /home/pi/iipzy-updater-a
git clone -q "http://github.com/KRobesky/iipzy-shared.git"
git clone -q "http://github.com/KRobesky/iipzy-updater.git"
# 
# install  iipzy-updater stuff
# 
cd /home/pi/iipzy-updater-a/iipzy-shared
npm i 2> /dev/null
cd /home/pi/iipzy-updater-a/iipzy-updater
npm i 2> /dev/null
#
echo =================================== 

if [ ! -z "$dcPassword" ]; then
	echo ====================================
	echo Install iipzy-tc
	echo ====================================
	# 
	cd /home/pi/iipzy-tc-a
	git clone -q "http://github.com/KRobesky/iipzy-shared.git"
	git clone -q "http://github.com/KRobesky/iipzy-tc.git"
	# 
	# install  iipzy-tc stuff
	# 
	cd /home/pi/iipzy-tc-a/iipzy-shared
	npm i 2> /dev/null
	cd /home/pi/iipzy-tc-a/iipzy-tc
	node /home/pi/iipzy-encrypt-a/iipzy-encrypt/src/index.js -d -in src.sec -out src.tar -p $dcPassword
	tar -xvf src.tar
	rm -f src.sec
	rm -f src.tar
	npm i 2> /dev/null
fi
# 
# 	- test
# 
# 	npm start
# 
echo ====================================
echo Install network monitoring tools
echo ====================================
# 
# For network monitor, promiscuous mode
# 
# 	the file /etc/network/interfaces...
# 
# 		#  interfaces(5) file used by ifup(8) and ifdown(8)
# 
# 		#  Please note that this file is written to be used with dhcpcd
# 		#  For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
# 
# 		#  Include files from /etc/network/interfaces.d:
# 		source-directory /etc/network/interfaces.d
# 
# 		auto eth0
# 		iface eth0 inet manual
# 		        up ifconfig eth0 promisc up
# 		        down ifconfig eth0 promisc down
# 
#//?? cp /home/pi/iipzy-core-a/iipzy-core/src/extraResources/interfaces /etc/network/interfaces
# 
# For Bonjour monitoring in iipzy-core
# 
cd /home/pi/iipzy-core-a/iipzy-core
# 
# 	- install libpcap-dev
# 
#//?? already installed - opkg install libpcap-dev
# 
#//?? fails  2023-03-03 npm i 2> /dev/null pcap
#//?? installed by 01-install-os.sh opkg install arp-scan
#//?? not needed - opkg install nbtscan
# 
opkg install avahi-utils
# 
# For cpu monitoring
# 
opkg install sysstat
#
echo =================================== 
echo Install Sentinel services.
echo =================================== 
#
cd /home/pi/iipzy-core-a/iipzy-core
cp src/extraResources/iipzy-core-a-openwrt.service $SERVICE_PATH/iipzy-core-a.service
cp src/extraResources/iipzy-core-b-openwrt.service $SERVICE_PATH/iipzy-core-b.service
chmod 777 $SERVICE_PATH/iipzy-core-a.service
chmod 777 $SERVICE_PATH/iipzy-core-b.service
$SERVICE_PATH/iipzy-core-a.service enable
# 
echo =================================== 
echo Install Sentinel Admin services
echo =================================== 
# 
cd /home/pi/iipzy-sentinel-admin-a/iipzy-sentinel-admin
cp src/extraResources/iipzy-sentinel-admin-a-openwrt.service $SERVICE_PATH/iipzy-sentinel-admin-a.service
cp src/extraResources/iipzy-sentinel-admin-b-openwrt.service $SERVICE_PATH/iipzy-sentinel-admin-b.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-admin-a.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-admin-b.service
$SERVICE_PATH/iipzy-sentinel-admin-a.service enable
#
echo =================================== 
echo Install Sentinel-web services
echo =================================== 
# 
cd /home/pi/iipzy-sentinel-web-a/iipzy-sentinel-web/
cp src/extraResources/iipzy-sentinel-web-a-openwrt.service $SERVICE_PATH/iipzy-sentinel-web-a.service
cp src/extraResources/iipzy-sentinel-web-b-openwrt.service $SERVICE_PATH/iipzy-sentinel-web-b.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-web-a.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-web-b.service
$SERVICE_PATH/iipzy-sentinel-web-a.service enable
# 
echo =================================== 
echo Install Sentinel-web-client-proxy services
echo =================================== 
#
cd /home/pi/iipzy-sentinel-web-client-proxy-a/iipzy-sentinel-web-client-proxy 
cp src/extraResources/iipzy-sentinel-web-client-proxy-a-openwrt.service $SERVICE_PATH/iipzy-sentinel-web-client-proxy-a.service
cp src/extraResources/iipzy-sentinel-web-client-proxy-b-openwrt.service $SERVICE_PATH/iipzy-sentinel-web-client-proxy-b.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-web-client-proxy-a.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-web-client-proxy-b.service
$SERVICE_PATH/iipzy-sentinel-web-client-proxy-a.service enable
# 

echo =================================== 
echo Install Updater services
echo =================================== 
# 
cd /home/pi/iipzy-updater-a/iipzy-updater
cp src/extraResources/iipzy-updater-a-openwrt.service $SERVICE_PATH/iipzy-updater-a.service
cp src/extraResources/iipzy-updater-b-openwrt.service $SERVICE_PATH/iipzy-updater-b.service
chmod 777 $SERVICE_PATH/iipzy-updater-a.service
chmod 777 $SERVICE_PATH/iipzy-updater-b.service
$SERVICE_PATH/iipzy-updater-a.service enable
# 
if [ ! -z "$dcPassword" ]; then
	echo =================================== 
	echo Install tc services
	echo =================================== 
	# 
	cd /home/pi/iipzy-tc-a/iipzy-tc
	cp src/extraResources/iipzy-tc-a-openwrt.service $SERVICE_PATH/iipzy-tc-a.service
	cp src/extraResources/iipzy-tc-b-openwrt.service $SERVICE_PATH/iipzy-tc-b.service
	chmod 777 $SERVICE_PATH/iipzy-tc-a.service
	chmod 777 $SERVICE_PATH/iipzy-tc-b.service
	#$SERVICE_PATH/iipzy-tc-a.service enable
	cp src/services/tc-config /usr/sbin/tc-config
	chmod 777 /usr/sbin/tc-config
fi
# 
echo =================================== 
echo Install redis service.
echo =================================== 
#
cd /home/pi/iipzy-core-a/iipzy-core
cp src/extraResources/redis-server.service $SERVICE_PATH/redis-server.service
chmod 777 $SERVICE_PATH/redis-server.service
$SERVICE_PATH/redis-server.service enable
# 
echo =================================== 
echo Install for RemoteSSH
echo =================================== 
#
opkg install sshpass
cp -f /root/workspace/bin/ssh-remote /usr/bin/ssh-remote
chmod 777 /usr/bin/ssh-remote
cp -f /root/workspace/dot_ssh/known_hosts /root/.ssh/known_hosts
chmod 0644 /root/.ssh/known_hosts
# 
touch /root/02-install-iipzy-done.txt
sync

echo =================================== 
echo Enable tc
echo =================================== 
if [ ! -z "$dcPassword" ]; then
	tc-config -e
fi

echo Finishing...
exit $EXIT_OK
