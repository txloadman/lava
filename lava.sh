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
PEERS="37fc77cca6c945d12c6e54166c3b9be2802ad1e6@lava-testnet.nodejumper.io:27656,4c50601b49951a90204e72371e9efb453092f824@194.61.28.72:26656,9872ab6a76199fcbeca1f7f791755e726aa97686@116.202.165.116:11656,ef38861694f07881410c1b1c5852c72050831d68@95.214.55.74:26656,20c13bd0d972acba5588493fb528b558a0317013@38.242.133.203:26656,3f0eb55b386427af17829b8ec98fd367a2fc469f@135.181.183.93:11656,acc3fe0b067e10b55c060b2f740d6193bf15a315@15.204.207.179:26656,b4d53b1e7a2fee2192a30e411ba83136c07ab595@161.97.147.107:26656,3be826c2d20009f17d067833a2adfd679b19394d@65.21.170.3:34656,71f6af45c867266f81d81193013fcb4137351355@194.163.155.84:56656,feb2350c874241e37b5769ee47f79308a23fe251@65.109.88.107:56656,f137232fd25d5c3adc6d3f6cffa879beafe17768@89.250.150.241:26656,0314d53cc790860fb51f36ac656a19789800ce5c@176.103.222.20:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@34.246.190.1:26656,eb7832932626c1c636d16e0beb49e0e4498fbd5e@65.108.231.124:20656,f0cd0858a15ec8c4e79e46ff7a1ea600ceec91d0@5.161.183.219:26656,8c120c2b9b1379ce513b0017422d537cb284e067@86.111.48.172:26656,810bdfb3e88f4872995f9a05b6298c1bf3d20fe0@65.108.105.48:19956,ec8065014ed4814b12c884ed528b96f281104528@65.21.131.215:26686,64df498c92b9ccaf78012229d399aa34a014f087@65.109.122.105:56659,3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@3.252.219.158:26656,8ac83e364622bc42fd62c6251ceb78ead6e4908c@89.23.110.233:12656,5676c8606f23471e220f8bf7317498a61bb93194@65.21.134.202:26686,f8d1b018326ceefbcd86d014e86e54582bf379f8@34.159.173.227:23556,fe6fa7efac512c790bbe6167570e207af5f947ba@167.235.84.166:26656,66d2aa299031887bd1b0a4ba366d9b490c78de6f@104.248.115.19:28656,edb83d47684250cd4c65fb3c0f98eeb09c974ca0@167.235.197.30:26656,d8900913c64c2d7894d13ba35fe6c3e7c346015a@95.31.224.15:36656,13a9209a4d08803a3becac57de8eb02dd51f8f41@65.109.23.114:19956,8cc0e66889c214d721e3fb34083da4c1edafa8ed@65.109.225.86:36656,8ffa4dbef4c0b2a1dc1172760914e2df1468fb22@178.63.8.245:60756,4e0a2772bb3672e54c2ea655c30abdac62191f14@45.84.138.66:18656,1b0d8d5c3364ba5f9fdea7bb2b5d52107c343224@95.217.186.181:26656,2da2e10009a11cbdd56f7f272186eef06d805ef7@178.63.26.94:44656,d9703df8c0e5eef6c0766217d611a13ed6ee8d95@88.99.33.248:26656,2a419b0feb095886371754bfe4ca1fa93ddf740f@34.27.248.220:28656,14110234a060fc0d9568fb43a32c8b6b0f0f8cc2@65.108.240.151:26656,4f8258e4a304b09390e86d07c5ede03126249329@89.116.30.72:36656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:44656,c143f3b22445c530beff4b401442e4be9474a060@80.76.235.194:6084,433be6210ad6350bebebad68ec50d3e0d90cb305@217.13.223.167:60856,0adbe1e790b58d19cc53a9839059a95d7d5d7aba@65.109.70.23:19956,6171a52cf0ffc1706409d2dcec56c1db81c86aae@176.103.222.17:26656,15480dd0fcccdf317d11993ff4c5d0098bc48a47@78.46.106.75:11656,8d5e90663aa8749ba955f4a2c91c8f638ed3bcfd@168.119.180.90:26656,3bc69361b1f03a52d63c31cf5b87a058e7a9385a@77.40.50.164:26656,23c1215defd5395cada717c225da8065c4d93193@159.69.88.206:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@185.16.39.172:27066,7f2543dc5094d25e1ffdd8542e15bbb1d5cc42f2@86.111.48.171:26656,4769e25b129234f050a49e70d5efa2c372266b84@91.107.242.217:38656,0c548b2704594c7929b713de4c6985b9d9f03b8a@194.163.184.46:27656"

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
