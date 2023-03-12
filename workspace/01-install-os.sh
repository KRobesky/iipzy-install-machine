#!/bin/bash

#declare -r    DEFAULT_CLIENT_HARDWARE_ID='23'	# mino
declare -r    DEFAULT_LAN_INTERFACE='eth1'
declare -r    DEFAULT_WAN_INTERFACE='eth0'
declare -r -i EXIT_ERROR=1
declare -r -i EXIT_LOCKED=4
declare -r -i EXIT_NO_NS=3
declare -r -i EXIT_OK=0
declare -r -i EXIT_USAGE=2
declare -r	  JAVA_PATH='/overlay/opt/java-1.8-openjdk/bin'

#declare       certificateAuthorityName='mayags.net'
#declare       certificateAuthorityServer='https://ca.mayags.net'
#declare       domainName='mayags.net'
#declare       hacksOnly=false
#declare       hardwareId=$DEFAULT_CLIENT_HARDWARE_ID
declare       interactive=false
declare       lannic=$DEFAULT_LAN_INTERFACE
declare       wannic=$DEFAULT_WAN_INTERFACE

# Errors are when a service script cannot perform the action requested 
# because something is wrong (e.g., program invocation is incorrect).

function Error {
	echo Error "$@"
	return 1
}

#function CreateFolders
#{
#	echo "Creating folders..."
#
#	mkdir /etc/inspeed
#	mkdir /var/lib/inspeed
#	mkdir /var/lib/inspeed/sentinel
#	mkdir /per
#	mkdir /per/lib
#	mkdir /per/lib/inspeed
#	mkdir /per/lib/inspeed/sentinel
#	mkdir /per/log
#	mkdir /usr/lib/inspeed
#
#	echo "Presence of this file is used by various components to determine if the host os is OpenWrt" > /etc/inspeed/os_openwrt
#}

#function InstallHacks
#{
#	echo 'Installing hacks...'
#
#	# /usr/sbin
#	cp -f /root/workspace/hacks/to-bin/* /usr/sbin/.
#	arr=( $(ls /root/workspace/hacks/to-bin ) )
#	for i in "${arr[@]}"
#	do
#		echo "installing /usr/sbin/$i"
#		# set as executable
#		chmod 0755 "/usr/sbin/$i"
#	done
#
#	# /usr/lib/inspeed
#	cp -f /root/workspace/hacks/to-lib/* /usr/lib/inspeed/.
#	arr=( $(ls /root/workspace/hacks/to-lib ) )
#	for i in "${arr[@]}"
#	do
#		echo "installing /usr/lib/inspeed/$i"
#		# set as executable
#	   	chmod 0755 "/usr/lib/inspeed/$i"
#	done
#
#	# /usr/lib/python2.7-site-packages
#	cp -f /root/workspace/hacks/to-python2.7-site-packages/* /usr/lib/python2.7/site-packages/.
#	arr=( $(ls /root/workspace/hacks/to-python2.7-site-packages ) )
#	for i in "${arr[@]}"
#	do
#		echo "installing /usr/lib/python2.7/site-packages/$i"
#		# set as executable
#	   	chmod 0755 "/usr/lib/python2.7/site-packages/$i"
#	done
#
#	# sentinel
#	cp -f /root/workspace/hacks/sentinel/* /usr/sbin/.
#}

#function InstallIQSPackages
#{
#	echo "Expanding Packages..."
#
#	cd /root/workspace/iqs-packages
#
#	tarfile=$( ls *.tar )
#	tar -xvf $tarfile
#
#	echo "Installing IQS Packages..."
#
#	arr=( $(ls /root/workspace/iqs-packages ) )
#	for i in "${arr[@]}"
#	do
#		opkg install "/root/workspace/iqs-packages/$i"
#	done
#
#	# disable auto activation
#	chmod 644 /etc/init.d/serialnumber
#}

function InstallNeededPackages
{
	echo =================================== 
	echo "Installing needed packages..."
	echo =================================== 

	opkg update
	opkg install getopt
	opkg remove iperf3
##--	opkg install iperf3-ssl	# for insp-iperf3
	opkg install jq
	opkg install nss-utils
	opkg install openssl-util
	opkg install libhiredis
	opkg install grep
	opkg install diffutils	# for building
	opkg install sysstat
	opkg install iputils-arping
	opkg install gcc
	opkg install make
	opkg install arp-scan
	opkg install arp-scan-database
	opkg install whereis
	opkg install conntrack
	opkg install iftop
	opkg install procps-ng-ps
	opkg install script-utils
	opkg install lsblk
	opkg install uuidgen
	opkg install wall
	opkg install coreutils-stat
	opkg install curl
	opkg install libcurl4
	opkg install wget-ssl
	opkg install procps-ng-vmstat
	opkg install tcpdump
	opkg install zoneinfo-all

	# -- tar that works
	echo =================================== 
	echo "*** install tar that works"
	echo =================================== 
	opkg upgrade tar

	# -- remove built-in web server
	echo =================================== 
	echo "*** remove built-in web server"
	echo =================================== 
	opkg remove uhttpd --force-depends
	rm -f /etc/config/uhttpd.

	# -- remove adblock
	echo =================================== 
	echo "*** remove adblock"
	echo =================================== 
	opkg remove adblock --force-depends
	rm -f /etc/config/uhttpd.

	# -- disable firewall
	echo =================================== 
	echo "*** disable firewall"
	echo =================================== 
	opkg remove firewall --force-depends

	# -- disable built-in qos
	echo =================================== 
	echo "*** disable built-in qos"
	echo =================================== 
	opkg remove qos-scripts

	echo =================================== 
	echo "Installing 3rd party Packages..."
	echo =================================== 
	arr=( $(ls /root/workspace/3rd-party-packages ) )
	for i in "${arr[@]}"
	do
		opkg install "/root/workspace/3rd-party-packages/$i"
	done

	#java
	echo =================================== 
	echo "*** install java"
	echo =================================== 
	# -- fixup bash path to include java
	export PATH="$PATH:$JAVA_PATH"
	sed -i '/export PATH=/c\export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/overlay/opt/java-1.8-openjdk/bin"' /etc/profile
	echo =================================== 
	echo "*** check java"
	echo =================================== 
	java -version

	# -- redis
	echo =================================== 
	echo "*** check redis"
	echo =================================== 
	redis-cli --version

##--	# -- perl for tunpinger
##--	echo "*** install perl"
##--	opkg install perl
##--	echo "*** check perl"
##--	perl --version
##--	opkg install perlbase-cpan
##--	opkg list | grep perlbase-| awk '{print $1}' | xargs opkg install
##--	opkg install make curl tar wget
##--	opkg install perl-test-warn
##--	opkg install perl-test-harness --force-overwrite
##--	echo "*** install perl - Test::More"
##--	curl -L https://cpanmin.us | perl - Test::More
##--	echo "*** install perl - ExtUtils::CBuilder"
##--	curl -L https://cpanmin.us | perl - ExtUtils::CBuilder
##--	echo "*** install perl - ExtUtils::MakeMaker --force"
##--	curl -L https://cpanmin.us | perl - ExtUtils::MakeMaker --force
##--	echo "*** install perl - App::cpanminus"
##--	curl -L https://cpanmin.us | perl - App::cpanminus
##--	tar xvf CPAN-2.28.tar.gz
##--	
##--	echo "*** install perl CPAN"
##--	cd CPAN-2.28/
##--	perl Makefile.PL
##--	make
##--	make install
##--	cd ..
##--	opkg install pkg-config
##--	opkg install coreutils-install
##--	echo "**********************************************************************"
##--	echo "**********************************************************************"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                           ANSWER yes                             **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**                                                                  **"
##--	echo "**********************************************************************"
##--	echo "**********************************************************************"
##--	echo "*** install perl cpan Redis"
##--	cpan -f -i Redis
##--	echo "*** install perl cpan JSON"
##--	cpan -f -i JSON
##--	echo "*** install perl cpan Text::Unidecode"
##--	cpan -f -i Text::Unidecode
##--
##--	# python3 for ping-stats, et.al.
##--
##--	#-obsolete-	echo "*** install python"
##--	#-obsolete-	opkg install python
##--	#-obsolete-	opkg install rrdtool1
##--	#-obsolete-	opkg install python-dev
##--	#-obsolete-	opkg install python-pip
##--	#-obsolete-	pip install configure
##--	#-obsolete-	pip install redis
##--	#-obsolete-	pip install --upgrade pip
##--	#-obsolete-	pip install -U setuptools
##--	#-obsolete-	pip install install
##--	#-obsolete-	pip install netifaces  # problem here
##--	#-obsolete-	pip install docopt
##--
##--	echo "*** install python3"
##--	opkg install python3
##--	opkg install python3-dev
##--	opkg install python3-pip
##--	opkg install python3-netifaces
##--	opkg install rrdtool1
##--	# link to python for nanoPi R4S - should be a no-op for nanoPi R5S
##--   	ln -s /usr/bin/python3 /usr/bin/python
##--   	ln -s /usr/bin/python3-config /usr/bin/python-config
##--	pip3 install --upgrade pip
##--	pip3 install wheel					# //??
##--	pip3 install configure
##--	pip3 install redis
##--	pip3 install -U setuptools
##--	pip3 install install
##--	pip3 install netifaces  # problem here
##--	pip3 install docopt

	echo =================================== 
	echo "*** install ./bin to /usr/bin"
	echo =================================== 
	cd bin
	cp -pf * /usr/bin/.
	arr=( $(ls * ) )
	for i in "${arr[@]}"
	do
		echo "installing /usr/bin/$i"
		# set as executable
		chmod 0777 "/usr/bin/$i"
	done
	cd ..

	echo "iperf3 $(iperf3 -version)"

	echo =================================== 
	echo "*** install node.js"
	echo =================================== 
	opkg install node
	opkg install node-npm
	node -v
}

function IsNicUp # [interface]
{
	local nic="$1"
	#
	local pingopt=''
	#
	[ -n "$nic" ] && pingopt="-I $nic"
	for ((i=0; i<3; i++)); do
		for ip in 8.8.8.8; do
			ping $pingopt -c 3 $ip > /dev/null 2>&1 && echo && return 0
		done
		echo -n '.'
	done
	echo
	return 1
}

function ProcessArguments # see below for the options
{
	local canameNext=false
	local caserverNext=false
	local domainNameNext=false
	while [ $# -gt 0 ]; do
		[ "$1" = '-can' ] && canameNext=true && shift && continue
		[ "$1" = '-cas' ] && caserverNext=true && shift && continue
		[ "$1" = '-dn' ] && domainNameNext=true && shift && continue
		[ "$1" = '-hacks' ] && hacksOnly=true && shift && continue
		[ "$1" = '-hid' ] && hardwareIdNext=true && shift && continue
		$canameNext && certificateAuthorityName="$1" && canameNext=false && shift && continue
		$caserverNext && certificateAuthorityServer="$1" && caserverNext=false && shift && continue
		$domainNameNext && domainName="$1" && domainNameNext=false && shift && continue
	done
}

function Setup_rc_local
{
	echo =================================== 
	echo 'Setting up rc.local ...'
	echo =================================== 

	#//?? TODO replace with sed...
	cat <<-EOF > /etc/rc.local
		# Put your custom commands here that should be executed once
		# the system init finished. By default this file does nothing.

		/usr/bin/lcd2usb_echo &

		board=$(cat /tmp/sysinfo/board_name | cut -d , -f2)
		if [ ! -e /etc/firstboot_${board} ]; then
		    /root/setup.sh
		    touch /etc/firstboot_${board}
		fi
		/bin/mount -a

		#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

		# NB:  For debugging, link /var/log to permanent storage
		echo "running rc.local setting up permanent log dirs..." > /root/rc_local.txt
		echo ===========================================
		echo 'Setting up logging to permanent directory'
		echo ===========================================
		mkdir /per
		mkdir /per/log
		mkdir /per/log/iipzy

		mv /var/log /var/log.org
		ln -s /per/log /var/log

##--		iqs-startup

		echo "running rc.local ..." >> /root/rc_local.txt

		exit 0
	EOF
}

function SetupBasicNetworking 
{
	echo =================================== 
	echo 'Setting up basic networking ...'
	echo =================================== 

	# bridging

	cat <<-EOF > /etc/config/network
		# Generated by install-machine. bridge mode.
		config interface 'loopback'
		        option ifname 'lo'
		        option proto 'static'
		        option ipaddr '127.0.0.1'
		        option netmask '255.0.0.0'

		config globals 'globals'
		        option ula_prefix 'fd00:ab:cd::/48'

		config interface 'lan'
		        option type 'bridge'
		        option ifname 'eth0 eth1'
		        option proto 'dhcp'

		config interface 'wan'
		        option ifname 'eth0'
	EOF

##--	# add centos style config scripts for core software.
##--
##--	mkdir -p /etc/sysconfig/network-scripts
##--
##--	cat <<-EOF > /etc/sysconfig/network-scripts/ifcfg-br0
##--		DEVICE=br0
##--		BOOTPROTO=dhcp
##--		ONBOOT=yes
##--		TYPE=Bridge
##--	EOF
##--
##--	cat <<-EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
##--		DEVICE=eth0
##--		TYPE=Ethernet
##--		BOOTPROTO=none
##--		ONBOOT=yes
##--		BRIDGE=br0
##--	EOF
##--
##--	cat <<-EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
##--		DEVICE=eth1
##--		TYPE=Ethernet
##--		BOOTPROTO=none
##--		ONBOOT=yes
##--		BRIDGE=br0
##--	EOF

	# restart network
	#service network reload
	/etc/init.d/network reload

	# ip tables, save rules
																					
	## reset ip tables.
	#insp -d
	#iptables-save > /etc/inspeed/iptables-config
	#ip6tables-save > /etc/inspeed/ip6tables-config
}

function SetupLogging #
{
	echo =================================== 
	echo 'Setting up logging to /var/log/messages'
	echo =================================== 

	sed -i "/option urandom_seed/a \ \ \ \ \ \ \ \ option log_size '1024'" /etc/config/system
	sed -i "/option urandom_seed/a \ \ \ \ \ \ \ \ option log_remote '0'" /etc/config/system
	#sed -i "/option urandom_seed/a \ \ \ \ \ \ \ \ option log_file '/var/log/messages'" /etc/config/system
	# NB:  For debugging, link /var/log to permanent storage
	sed -i "/option urandom_seed/a \ \ \ \ \ \ \ \ option log_file '/per/log/messages'" /etc/config/system
}

#function SetupProduct
#{
#	echo 'Setting up product...'
#	export PATH="$PATH:$JAVA_PATH"
#	setrunmodeprod -hardware $hardwareId -domainname $domainName -caserver $certificateAuthorityServer -caname $certificateAuthorityName -deflan $lannic -defwan $wannic
#}

#function SetupRemoteSSH
#{
#	echo 'Setting up ssh keys and known_hosts'
#
#	mkdir -p /root/.ssh
#	# private key
#	cp -f /root/workspace/dot_ssh/id_rsa /root/.ssh/id_rsa
#	chmod 0600 /root/.ssh/id_rsa
#	# public key
#	cp -f /root/workspace/dot_ssh/id_rsa.pub /root/.ssh/id_rsa.pub
#	chmod 0644 /root/.ssh/id_rsa.pub
#	# known hosts
#	cp -f /root/workspace/dot_ssh/known_hosts /root/.ssh/known_hosts
#	chmod 0644 /root/.ssh/known_hosts
#}

function SetupTimezone #
{
	echo 'Setting up timezone to UTC'
	cp -p /etc/config/system /etc/config/system.ORG
	echo 'UTC' > /etc/TZ
	# change timezone to UTC
	sed -i "s/.*option timezone.*/\ \ \ \ \ \ \ \ option timezone 'UTC'/" /etc/config/system
	# change zonename to UTC
	sed -i "s/.*option zonename.*/\ \ \ \ \ \ \ \ option zonename 'UTC'/" /etc/config/system
	# show current time
	date
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

#============
# starts here
#============

ProcessArguments "$@"

WaitForTimeSet

if [ "$hacksOnly" = "true" ]; then
	InstallHacks
	echo "Exiting after installing hacks..."
	exit $EXIT_OK
fi

date

echo 'Verify that the WAN network interface is operational ...'
if ! IsNicUp "$wannic"; then
	echo "WAN $wannic is being started ..."
	ifup $wannic && sleep 10 # pause for a moment for DHCP
	IsNicUp "$wannic" || Error "Network is not up.  Maybe you don't have the WAN plugged in.  Fix and try again." || exit $EXIT_ERROR
fi

##--CreateFolders

SetupTimezone

InstallNeededPackages

Setup_rc_local

SetupLogging

#InstallIQSPackages

sync

echo "**********************************************************************"
echo "**********************************************************************"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                             DONE                                 **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**                                                                  **"
echo "**********************************************************************"
echo "**********************************************************************"

echo =============================================
echo 'Will reboot after setting up networking'
echo 'NB: wan ip address will change'
echo ============================================= 

SetupBasicNetworking

#InstallHacks

#SetupProduct

#SetupRemoteSSH

touch /root/01-install-os-done.txt

sync

date

reboot

exit $EXIT_OK
