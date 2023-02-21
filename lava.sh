#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export LAVA_CHAIN_ID=lava-testnet-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

# download binary
cd $HOME
rm -rf lava
git clone https://github.com/lavanet/lava.git
cd lava
git checkout v0.6.0
make install
lavad version

# config
lavad config chain-id $LAVA_CHAIN_ID
lavad config keyring-backend test

# init
lavad init $NODENAME --chain-id $LAVA_CHAIN_ID

# download genesis and addrbook
curl -s https://raw.githubusercontent.com/K433QLtr6RA9ExEq/GHFkqmTzpdNLDd6T/main/testnet-1/genesis_json/genesis.json > $HOME/.lava/config/genesis.json
curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/addrbook.json > $HOME/.lava/config/addrbook.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ulava\"/" $HOME/.lava/config/app.toml

# set peers and seeds
SEEDS=""
PEERS="37fc77cca6c945d12c6e54166c3b9be2802ad1e6@lava-testnet.nodejumper.io:27656,14ae45e7f2ff7491cfa686a8fcac7cc095bc38ff@213.239.217.52:39656,f9190a58670c07f8202abfd9b5b14187b18d755b@144.76.97.251:27656,24a2bb2d06343b0f74ed0a6dc1d409ce0d996451@188.40.98.169:27656,f7c1a998b8ef7cae7e38b0eff64d96206924e957@45.84.138.167:26656,bd1e1f8df77e7b61200c490c9fabe6bbc4412d4e@91.223.3.144:26856,abbad4acf9360b250764ef660b5a25a4ec58245f@172.104.159.69:55676,3f0eb55b386427af17829b8ec98fd367a2fc469f@135.181.183.93:11656,276c73534246fb9ec48d5c72ebd62c42e2f96462@157.90.17.150:26656,3693ea5a8a9c0590440a7d6c9a98a022ce3b2455@65.109.92.79:20656,57474bd0977b3ed65cf23086b6d1d92bf00d50d0@207.180.236.122:31656"

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.lava/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.lava/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.lava/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.lava/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.lava/config/config.toml

# create service
sudo tee /etc/systemd/system/lavad.service > /dev/null << EOF
[Unit]
Description=Lava Network Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which lavad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

lavad tendermint unsafe-reset-all --home $HOME/.lava --keep-addr-book

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/lava-testnet/ | egrep -o ">lava-testnet-1.*\.tar.lz4" | tr -d ">")
curl https://snapshots1-testnet.nodejumper.io/lava-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.lava

# start service
sudo systemctl daemon-reload
sudo systemctl enable lavad
sudo systemctl start lavad

break
;;

"Create Wallet")
lavad keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
LAVA_WALLET_ADDRESS=$(lavad keys show $WALLET -a)
LAVA_VALOPER_ADDRESS=$(lavad keys show $WALLET --bech val -a)
echo 'export LAVA_WALLET_ADDRESS='${LAVA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export LAVA_VALOPER_ADDRESS='${LAVA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
lavad tx staking create-validator \
  --amount 10000ulava \
  --from wallet \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(lavad tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id lava-testnet-1 \
  -y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
