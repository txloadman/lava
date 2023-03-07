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
git checkout v0.7.0
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
PEERS="37fc77cca6c945d12c6e54166c3b9be2802ad1e6@lava-testnet.nodejumper.io:27656,0efa60456219f5b7847ee21439aa8662c0a8e1b6@65.21.195.40:26056,9872ab6a76199fcbeca1f7f791755e726aa97686@116.202.165.116:11656,8f79bf6093fd728359f529a4a5214c0364749230@65.21.205.248:11656,f4223c735207cbf38a1d053d7a33531f82d12fc9@185.249.225.230:26656,3f0eb55b386427af17829b8ec98fd367a2fc469f@135.181.183.93:11656,acc3fe0b067e10b55c060b2f740d6193bf15a315@15.204.207.179:26656,c69f694a79b247f9fd404cab865f86f55296bd63@184.174.34.155:26656,3be826c2d20009f17d067833a2adfd679b19394d@65.21.170.3:34656,695f9e8dad50fa524ed96c4d5df7afe12963995f@65.108.124.219:38656,feb2350c874241e37b5769ee47f79308a23fe251@65.109.88.107:56656,f137232fd25d5c3adc6d3f6cffa879beafe17768@89.250.150.241:26656,0314d53cc790860fb51f36ac656a19789800ce5c@176.103.222.20:26656,db8b1d876480849784569b927a3cc6d27dcc05a1@65.108.229.93:31656,20b774774099ca20955584a94b603cd45e9184a4@159.69.95.76:26656,0925c475208d8e338907383ab87a094ad03c478e@65.109.55.186:40656,8c120c2b9b1379ce513b0017422d537cb284e067@86.111.48.172:26656,5e068fccd370b2f2e5ab4240a304323af6385f1f@172.93.110.154:27656,ec8065014ed4814b12c884ed528b96f281104528@65.21.131.215:26686,64df498c92b9ccaf78012229d399aa34a014f087@65.109.122.105:56659,013f0163d37428ed99eacd8ee84059da5c243981@5.161.132.217:26656,d38ba32cc262b23c49748428880315485e48963d@65.108.126.35:25656,5676c8606f23471e220f8bf7317498a61bb93194@65.21.134.202:26686,d5f51ff7adf797e7e4be5f303e75686f6d277886@213.239.207.165:29556,fb2b9d41678f3d1c9c0bdef1a87f2037b6b0088a@146.19.24.252:26666,8ef9baeaaf8e4e3c478c74b2334ab61d7190be72@92.255.253.6:56656,31478ee0c0521c7cfb3312b86ef490936b5ceb80@65.109.92.240:197,d8900913c64c2d7894d13ba35fe6c3e7c346015a@95.31.224.15:36656,13a9209a4d08803a3becac57de8eb02dd51f8f41@65.109.23.114:19956,2193d8b389cecc1e5b0bbbd181025c6549036c9e@217.160.201.92:29656,cb722cc36541920d3907cd67743db5444f53e80b@95.70.184.178:24656,18432dbb1238c416053bcbbc7b85b5f1258010a0@193.34.212.34:11134,dc1c37e340a191ac0eea7c561b4a3c8fba2ce80a@65.21.237.241:26656,2da2e10009a11cbdd56f7f272186eef06d805ef7@178.63.26.94:44656,67f122a00eb926ff49cf54b1032e57d7027a02b8@38.242.158.250:26656,3177033dfc8a88c0b1a4500e2812c74f41e9a32b@94.130.236.21:26656,14110234a060fc0d9568fb43a32c8b6b0f0f8cc2@65.108.240.151:26656,4769e25b129234f050a49e70d5efa2c372266b84@91.107.242.217:38656,9057ee9d3d9b3c42c184dc89a7b2a07026b81a45@31.220.76.131:26656,eb7832932626c1c636d16e0beb49e0e4498fbd5e@65.108.231.124:20656,b36a39d183383fa068f0db145b179bf8455a06f4@38.242.159.214:26656,f1782789e48a86873b925ed5065c24a7ee8fec06@34.125.142.94:20656,6171a52cf0ffc1706409d2dcec56c1db81c86aae@176.103.222.17:26656,15480dd0fcccdf317d11993ff4c5d0098bc48a47@78.46.106.75:11656,9ff4aa1369a5759a05e0f8a40ebec5dae57735e9@135.181.161.235:26656,66d2aa299031887bd1b0a4ba366d9b490c78de6f@104.248.115.19:28656,1a18bdd0c259d604cda023a5e03eba2a25f5c045@94.19.249.187:27656,853a7364bd7465b7ca6c790b5c6a6bb18152ac93@5.9.122.11:26656,c19965fe8a1ea3391d61d09cf589bca0781d29fd@162.19.217.52:26656,8a20f8f798c5073f0867812e691f54b5cd0dd65d@109.123.242.188:26656,3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@3.252.219.158:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.lava/config/config.toml

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
