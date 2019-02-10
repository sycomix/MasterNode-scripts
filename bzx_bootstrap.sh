#!/bin/bash

# Make sure curl is installed
apt-get -qq update
apt -qqy install curl jq
clear

BOOTSTRAPURL=$(curl -s https://github.com/WG91/MasterNode-scripts/releases/download/BZX/bootstrap.zip | cut -d '"' -f 4)
BOOTSTRAPARCHIVE="bootstrap.zip"

clear
echo "This script will refresh your masternode."
read -rp "Press Ctrl-C to abort or any other key to continue. " -n1 -s
clear

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root."
  exit 1
fi

USER=$(ps -o user= -p "$(pgrep buzzexcoind)")
USERHOME=$(eval echo "~$USER")

if [ -e /etc/systemd/system/buzzexcoin.service ]; then
  systemctl stop buzzexcoind
else
  su -c "buzzexcoin-cli stop" "$USER"
fi

echo "Refreshing node, please wait."

sleep 5

rm -rf "$USERHOME/.buzzexcoin/blocks"
rm -rf "$USERHOME/.buzzexcoin/chainstate"
rm -rf "$USERHOME/.buzzexcoin/sporks"
rm -rf "$USERHOME/.buzzexcoin/peers.dat"

cp "$USERHOME/.buzzexcoin/buzzexcoin.conf" "$USERHOME/.buzzexcoin/buzzexcoin.conf.backup"
sed -i '/^addnode/d' "$USERHOME/.buzzexcoin/buzzexcoin.conf"

echo "Installing bootstrap file..."
cd $USERHOME/.buzzexcoin/ && wget "$BOOTSTRAPURL" && unzip $BOOTSTRAPARCHIVE && rm $BOOTSTRAPARCHIVE

if [ -e /etc/systemd/system/buzzexcoin.service ]; then
  sudo systemctl start buzzexcoind
else
  su -c "buzzexcoind -daemon" "$USER"
fi

echo "Starting buzzexcoind, will check status in 60 seconds..."
sleep 60

clear

if ! systemctl status buzzexcoind | grep -q "active (running)"; then
  echo "ERROR: Failed to start buzzexcoind. Please contact support."
  exit
fi

echo "Waiting for wallet to load..."
until su -c "buzzexcoin-cli getinfo 2>/dev/null | grep -q \"version\"" "$USER"; do
  sleep 1;
done

clear

echo "Your masternode is syncing. Please wait for this process to finish."
echo "This can a few minutes. Do not close this window."
echo ""

until [ -n "$(buzzexcoin-cli getconnectioncount 2>/dev/null)"  ]; do
  sleep 1
done

until su -c "buzzexcoin-cli mnsync status 2>/dev/null | grep '\"IsBlockchainSynced\": true' > /dev/null" "$USER"; do 
  echo -ne "Current block: $(su -c "buzzexcoin-cli getblockcount" "$USER")\\r"
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
su -c "/usr/local/bin/buzzexcoin-cli startmasternode local false" "$USER"
sleep 1
clear
su -c "/usr/local/bin/buzzexcoin-cli masternode status" "$USER"
sleep 5

echo "" && echo "Masternode refresh completed." && echo ""
