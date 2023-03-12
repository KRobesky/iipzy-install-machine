#!/bin/bash
# Get image from https://www.raspberrypi.org/downloads/raspbian/ -- lite
# 
# Use DISKPART to initialize sd card
# 
# 	diskpart
# 	>list disk
# 	>select disk n
# 	>list disk
# 	>clean
# 	>list disk
# 	>create partition primary
# 	>list disk
# 	>exit
# 
# Use balenaEtcher to flash image to micro sd.
# 
# ====================================
# Enable SSH using connected keyboard and monitor/
# 	see https://www.raspberrypi.org/documentation/remote-access/ssh/
# ====================================
# 
# 	sudo systemctl enable ssh
# 	sudo systemctl start ssh
#	- note address.
#	ip addr
# 
# ====================================
# After this, use ssh
# ====================================
# 
# ====================================
# Install git
# ====================================
#
# fix up <username:password>@<git-repository> in the git clone request below.
#
#	sudo apt-get update
#
# 	sudo apt-get install git -y
# 
# 	git config --global user.name "User Name"
# 	git config --global user.email email@x.y
# 
# 	pwd
# 	/home/pi
# 	mkdir /home/pi/iipzy-service-a
# 	cd /home/pi/iipzy-service-a
# 	git init
# 	git remote add origin http://192.168.1.65/Bonobo.Git.Server/iipzy-pi
# 
# Get this install script
# 
# 	git clone http://<username:password>@<git-repository>/iipzy-configs-private.git
# 
# ====================================
# Run this script
# ====================================
# 	/bin/bash /home/pi/iipzy-service-a/iipzy-configs-private/iipzy-pi-config/ApplianceInitialSetup.sh
# 
declare -r -i EXIT_ERROR=1
declare -r -i EXIT_OK=0
declare -r	  SERVICE_PATH="/etc/init.d/"

##--declare	gitEmail=''
##--declare	gitPassword=''
##--declare	gitRepo=''
##--declare	gitRoot=''
##--declare	gitUserName=''

function ProcessArguments # see below for the options
{
	local gitEmailNext=false
	local gitPassNext=false
	local gitRepoNext=false
	local gitRootNext=false
	local gitUserNext=false
	while [ $# -gt 0 ]; do
		[ "$1" = '-gitemail' ] && gitEmailNext=true && shift && continue
		[ "$1" = '-gitpass' ] && gitPassNext=true && shift && continue
		[ "$1" = '-gitrepo' ] && gitRepoNext=true && shift && continue
		[ "$1" = '-gitroot' ] && gitRootNext=true && shift && continue
		[ "$1" = '-gituser' ] && gitUserNext=true && shift && continue
		$gitEmailNext && gitEmail="$1" && gitEmailNext=false && shift && continue
		$gitPassNext && gitPassword="$1" && gitPassNext=false && shift && continue
		$gitRepoNext && gitRepo="$1" && gitRepoNext=false && shift && continue
		$gitRootNext && gitRoot="$1" && gitRootNext=false && shift && continue
		$gitUserNext && gitUserName="$1" && gitUserNext=false && shift && continue
	done

	if [ "$gitEmail" = '' ]; then
		echo "-gitemail is missing"
		exit $EXIT_ERROR
	fi

	if [ "$gitPassword" = '' ]; then
		echo "-gitpass is missing"
		exit $EXIT_ERROR
	fi

	if [ "$gitRepo" = '' ]; then
		echo "-gitrepo is missing"
		exit $EXIT_ERROR
	fi

	if [ "$gitRoot" = '' ]; then
		echo "-gitroot is missing"
		exit $EXIT_ERROR
	fi

	if [ "$gitUserName" = '' ]; then
		echo "-gituser is missing"
		exit $EXIT_ERROR
	fi

	echo "-gitemail: $gitEmail"
	echo "-gitpass:  $gitPassword"
	echo "-gitrepo:  $gitRepo"
	echo "-gitroot:  $gitRoot"
	echo "-gituser:  $gitUserName"
}

#====================================================
# Starts here.
#
# We assume we're starting after 01-install-os
#====================================================

##-- not needed ProcessArguments "$@"

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
mkdir /home/pi/iipzy-service-a
mkdir /home/pi/iipzy-service-b
mkdir /home/pi/iipzy-sentinel-web-a
mkdir /home/pi/iipzy-sentinel-web-b
mkdir /home/pi/iipzy-sentinel-admin-a
mkdir /home/pi/iipzy-sentinel-admin-b
mkdir /home/pi/iipzy-updater-a
mkdir /home/pi/iipzy-updater-b
mkdir /home/pi/iipzy-updater-config
cd /home/pi/iipzy-service-a
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
# 
echo ====================================
echo Install static web server
echo ====================================
#
npm install -g serve
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
echo '{"serverAddress":"iipzy.net:8001"}' > /etc/iipzy/iipzy.json
#
echo ====================================
echo Install iipzy-pi
echo ====================================
#				   `
cd /home/pi/iipzy-service-a
git clone "http://github.com/KRobesky/iipzy-shared.git"
git clone "http://github.com/KRobesky/iipzy-pi.git"

# 
# install iipzy-pi stuff
# 
cd /home/pi/iipzy-service-a
# 
cd /home/pi/iipzy-service-a/iipzy-shared
npm i
cd /home/pi/iipzy-service-a/iipzy-pi
npm i
#
echo ====================================
echo Install iipzy-sentinel-web-build
echo ====================================
# 
cd /home/pi/iipzy-sentinel-web-a
git clone "http://github.com/KRobesky/iipzy-sentinel-web-build.git"
##//??# 
##//??# install  iipzy-sentinel-web stuff
##//??# 
##//??cd /home/pi/iipzy-sentinel-web-a/iipzy-shared
##//??npm i
##//??cd /home/pi/iipzy-sentinel-web-a/iipzy-sentinel-web
##//??npm i
##//??#
##//??echo ====================================
##//??echo Build Sentinel-Web
##//??echo ====================================						 
##//??# 
##//??npm run build
##//??# 
##//??# 	- test
##//??# 
##//??# 	npm start
##//??# 
echo ====================================
echo Install iipzy-sentinel-admin
echo ====================================
# 
cd /home/pi/iipzy-sentinel-admin-a
git clone "http://github.com/KRobesky/iipzy-shared.git"
git clone "http://github.com/KRobesky/iipzy-sentinel-admin.git"
# 
# install  iipzy-sentinel-admin stuff
# 
cd /home/pi/iipzy-sentinel-admin-a/iipzy-shared
npm i
cd /home/pi/iipzy-sentinel-admin-a/iipzy-sentinel-admin
npm i
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
git clone "http://github.com/KRobesky/iipzy-shared.git"
git clone "http://github.com/KRobesky/iipzy-updater.git"
# 
# install  iipzy-updater stuff
# 
cd /home/pi/iipzy-updater-a/iipzy-shared
npm i
cd /home/pi/iipzy-updater-a/iipzy-updater
npm i

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
#//?? cp /home/pi/iipzy-service-a/iipzy-pi/src/extraResources/interfaces /etc/network/interfaces
# 
# For Bonjour monitoring in iipzy-pi
# 
cd /home/pi/iipzy-service-a/iipzy-pi
# 
# 	- install libpcap-dev
# 
#//?? already installed - opkg install libpcap-dev
# 
#//?? fails  2023-03-03 npm i pcap
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
cd /home/pi/iipzy-service-a/iipzy-pi
cp src/extraResources/iipzy-pi-a-openwrt.service $SERVICE_PATH/iipzy-pi-a.service
cp src/extraResources/iipzy-pi-b-openwrt.service $SERVICE_PATH/iipzy-pi-b.service
chmod 777 $SERVICE_PATH/iipzy-pi-a.service
chmod 777 $SERVICE_PATH/iipzy-pi-b.service
$SERVICE_PATH/iipzy-pi-a.service enable
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
cd /home/pi/iipzy-sentinel-web-a/iipzy-sentinel-web-build/
cp extraResources/iipzy-sentinel-web-a-openwrt.service $SERVICE_PATH/iipzy-sentinel-web-a.service
cp extraResources/iipzy-sentinel-web-b-openwrt.service $SERVICE_PATH/iipzy-sentinel-web-b.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-web-a.service
chmod 777 $SERVICE_PATH/iipzy-sentinel-web-b.service
$SERVICE_PATH/iipzy-sentinel-web-a.service enable
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
touch /root/02-install-iipzy-done.txt
sync
echo Exiting...
exit $EXIT_OK

echo =================================== 
echo Verify installation
echo =================================== 
# check iipzy logs directory
# 
ls -l /var/log/iipzy/
# 
# 	you should see something like...
# 
# 	total 3404
# 	-rw-r--r-- 1 pi pi 1745931 Oct  3 00:31 iipzy-pi-2019-10-03-00.log
# 	-rw-r--r-- 1 pi pi 1719438 Oct  3 00:31 iipzy-pi.log
# 	-rw-r--r-- 1 pi pi    3114 Oct  3 00:31 iipzy-updater-2019-10-03-00.log
# 	-rw-r--r-- 1 pi pi    3114 Oct  3 00:31 iipzy-updater.log
# 
echo =================================== 
echo Remove secret stuff
echo =================================== 
# 
rm -r -f cp /home/pi/iipzy-service-a/iipzy-configs-private
# 
#  check that services are running
# 	ps -Af | grep iipzy
# 	pi        8000     1 23 00:21 ?        00:00:05 /usr/bin/node /home/pi/iipzy-service-a/iipzy-pi/src/index.js
# 	pi        8409   787  0 00:22 pts/0    00:00:00 grep --color=auto iipzy
# 
echo =================================== 
echo Change password
echo =================================== 
# 
echo "pi:iipzy" | chpasswd
# 
echo =================================== 
echo reboot
echo =================================== 
# 
reboot
# 
# ====================================
# 
# Before shipping AND/OR making an image.
#
# 	- stop services.  Note which of "a" or "b" service is active (e.g., "iipzy-pi-a" vs "iipzy-pi-b")
#
# 	ps -Af | grep iipzy
# 	pi        1026     1  0 14:43 ?        00:00:05 /usr/bin/node /home/pi/iipzy-updater-b/iipzy-updater/src/index.js
# 	pi        2161     1  2 15:02 ?        00:01:04 /usr/bin/node /home/pi/iipzy-service-b/iipzy-pi/src/index.js
# 	pi        4924 27819  0 15:51 pts/0    00:00:00 grep --color=auto iipzy
#
#	systemctl stop iipzy-updater-b
#	systemctl stop iipzy-pi-b
# 	
# 	- remove state files from /etc/iipzy
# 	
# 	rm -r -f /etc/iipzy/*
# 	
# 	- initialize /etc/iipzy/iipzy.json
# 
#   echo '{"serverAddress":"iipzy.net:8001"}' > /etc/iipzy/iipzy_perm.json
# 
# 	- remove log files from /var/logs/iipzy/.
#
#	rm -r -f /var/log/iipzy/*
#
#	- change password
#
#	echo "pi:iipzy" | chpasswd
#
#	- zero out to minimize compressed size.  THIS TAKES A LONG TIME. ~30 minutes
#
#	opkg autoremove -y
#	opkg clean -y
#	cat /dev/zero >> zero.file;sync;rm zero.file;date
# 
# 	shutdown
# 
# ====================================
#
# Create archive of pi image
#
# ====================================
#
# Use Win32DiskImager to copy image from micro-sd card --> iipzy-server\RPI-images\iipzypi.img
#
# Use 7-zip to compress the .img file.
#

