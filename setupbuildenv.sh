#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function prepare_system() {
echo -e "Executing package update."
apt-get update >/dev/null 2>&1
echo -e "Installing required packages, part I: basics."
apt-get install -y build-essential libtool autotools-dev autoconf pkg-config libssl-dev >/dev/null 2>&1
apt-get install -y make automake git wget curl ufw bsdmainutils >/dev/null 2>&1
apt-get install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository."
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, part II: crypto-specific.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y libdb4.8-dev libdb4.8++-dev >/dev/null 2>&1
apt-get install -y libboost-all-dev >/dev/null 2>&1
apt-get install -y libminiupnpc-dev >/dev/null 2>&1
apt-get install -y libevent-dev >/dev/null 2>&1
apt-get install -y libgmp3-dev libzmq5 >/dev/null 2>&1
apt-get install -y libdb5.3++-dev >/dev/null 2>&1
apt-get install -y libqt5gui5 libqt5core5 libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler >/dev/null 2>&1
apt-get install -y libqrencode-dev >/dev/null 2>&1
echo -e "${GREEN}Adding openjdk PPA repository"
apt-add-repository -y ppa:openjdk-r/ppa >/dev/null 2>&1
echo -e "Installing required packages, part III: Android-specific.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y bc bison flex g++-multilib gcc-multilib gnupg gperf >/dev/null 2>&1
apt-get install -y lib32ncurses5-dev lib32readline6-dev lib32z1-dev libesd0-dev >/dev/null 2>&1
apt-get install -y liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils >/dev/null 2>&1
apt-get install -y lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev >/dev/null 2>&1
apt-get install -y imagemagick openjdk-lts >/dev/null 2>&1
apt-get update >/dev/null 2>&1
apt-get upgrade -y >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually.${NC}\n"
 exit 1
fi

clear
}

##### Main #####
clear
prepare_system
