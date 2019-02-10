#!/bin/bash

clear
echo "This script will refresh your masternode."
read -rp "Press Ctrl-C to abort or any other key to continue. " -n1 -s
clear

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root."
  exit 1
fi

if [ -e /etc/systemd/system/mqx.service ]; then
  systemctl stop mqx.service
else
  su -c "mqx-cli stop" "root"
fi

echo "Refreshing node, please wait."

sleep 5

rm -rf "/root/.mqx/blocks"
rm -rf "/root/.mqx/chainstate"
rm -rf "/root/.mqx/sporks"
rm -rf "/root/.mqx/peers.dat"

echo "Installing bootstrap file..."

cd /root/.mqx && wget https://github.com/WG91/MasterNode-scripts/releases/download/MQX/bootstrap.zip && unzip bootstrap.zip && rm bootstrap.zip

if [ -e /etc/systemd/system/mqx.service ]; then
  sudo systemctl start mqx.service
else
  su -c "mqxd -daemon" "root"
fi

echo "Starting mqx, will check status in 60 seconds..."
sleep 60

clear

if ! systemctl status mqx.service | grep -q "active (running)"; then
  echo "ERROR: Failed to start mqx. Please re-install using install script."
  exit
fi

echo "Waiting for wallet to load..."
until su -c "mqx-cli getinfo 2>/dev/null | grep -q \"version\"" "$USER"; do
  sleep 1;
done

clear

echo "Your masternode is syncing. Please wait for this process to finish."
echo "This can a few minutes. Do not close this window."
echo ""

until [ -n "$(mqx-cli getconnectioncount 2>/dev/null)"  ]; do
  sleep 1
done

until su -c "mqx-cli mnsync status 2>/dev/null | grep '\"IsBlockchainSynced\": true' > /dev/null" "$USER"; do 
  echo -ne "Current block: $(su -c "mqx-cli getblockcount" "$USER")\\r"
  sleep 1
done

clear

cat << EOL

Now, you need to start your masternode. If you haven't already, please add this
node to your masternode.conf now, restart and unlock your desktop wallet, go to
the Masternodes tab, select your new node and click "Start Alias."

EOL

read -rp "Press Enter to continue after you've done that. " -n1 -s

clear

sleep 1
su -c "/usr/local/bin/mqx-cli startmasternode local false" "$USER"
sleep 1
clear
su -c "/usr/local/bin/mqx-cli masternode status" "$USER"
sleep 5

echo "" && echo "Masternode refresh completed." && echo ""
