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
git clone https://github.com/lavanet/lava
cd lava
git checkout v0.4.3
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
PEERS="37fc77cca6c945d12c6e54166c3b9be2802ad1e6@lava-testnet.nodejumper.io:27656,d927303d07abf24b72f3eb8ae495ac02372e3908@91.195.101.78:26656,7a3ff12eda588f85ecb0da71def4bd736d65612f@95.217.224.252:26656,bc23a887d42f32ffb07bd60367411b4b36f9fa66@65.109.51.41:26656,4b82a658919cb7cc18e7aa5b9d49a75ef138c64e@44.196.143.228:26656,7e93260df1c1b6322b8ef229556264430cd83193@207.180.229.79:26656,fcbe43af6ef40fca686af83e13a8b03d1a6046e6@135.181.178.53:56656,b4d53b1e7a2fee2192a30e411ba83136c07ab595@161.97.147.107:26656,f68c57ca955420779773f9320a6b7710c2b29f73@188.191.36.222:26656,75dcbf4f1b4da2727466d35265116db8008da040@45.85.147.157:26656,7c197aa33e780d261ff8c2fd63cd254d7257c7bd@162.55.242.150:26656,9d5802ec3e10fbac150850ffdfa50f324e804b95@95.214.55.62:35656,c19965fe8a1ea3391d61d09cf589bca0781d29fd@162.19.217.52:26656,d7c350f9b16111f04a5fe391ec8ccbed5faee56e@86.48.1.218:26656,d3eb474a1f90d004e49638e384069c32d7dcc8a2@185.252.232.110:26656,3c47fd1662bcb17a4713c23e41d7b25e34478b8e@103.19.25.157:26672,035d086cc418352aba9e679e079f17391791ccc6@178.208.252.54:27656,07277038190e9eb8855a49b1a13d742d18d9bea5@65.108.41.172:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@185.16.39.172:27066,8cd81b9119e4aa45fe549dd12543de862457c989@38.242.155.47:26656,b7c3cedc778d93296f179373c3bc6a521e4b682e@65.109.69.160:30656,e1508bad98db2fbb0447ef0c342a2a104f5a63dd@65.108.238.217:11244,0561fed6e88f2167979e379436529861527d859d@65.109.92.148:61256,580d6c9be21f26a713881fc9dcb4ebafcc945eb6@159.65.16.202:26656,4f9120f706512162fbe4f39aac78b9924efbec58@65.109.92.235:11036,0516c4d11552b334a683bdb4410fa22ef7e3f8ba@65.21.239.60:11656,d38ba32cc262b23c49748428880315485e48963d@65.108.126.35:25656,62c47a4866e77aedf9f7baa4f8c5b1423c95e871@148.251.91.185:29656,397056c8cd7e2fce451d4f8e34ef24c0c9ffacba@176.9.44.113:26676,79a3b530b271b1f9b5e10617fcca9041c9f8f548@65.108.45.200:26858,4def696d8f04fc25c092dd957d453e8d10e32644@95.214.54.56:27656,24a2bb2d06343b0f74ed0a6dc1d409ce0d996451@188.40.98.169:27656,ffc88f95a277fc31fb43c926ad25ff724c8939b4@65.21.243.255:26656,1e0a1a338ee5ca33548384361929ef8a9b89a039@65.109.161.233:26656,f31c4dc121f37db1e0e24b49584bbbe4bbbba6c4@162.55.39.16:36656,276c73534246fb9ec48d5c72ebd62c42e2f96462@157.90.17.150:26656,a224f9703f714593974848dd23ed78688ba600a9@34.244.28.46:26656,39309f1ce3d7b6acf9714c749b67c7db6d3f615d@38.242.152.174:26656,51aeaa2c757989f720c904023c2dbedfc720f75e@23.88.5.169:27656,6b1d0465b3e2a32b5328e59eb75c38d88233b56f@80.82.215.19:60656,6c988ad39fef48abd5504fda547d561fb8a60c3a@130.185.119.243:33656,2c2353c872b0c5af562c518b1aa48a2649a4c927@65.108.199.62:11656,5524484358f731e0863ec473b0cb7a4531956325@178.18.246.170:26656,abbad4acf9360b250764ef660b5a25a4ec58245f@172.104.159.69:55676,810bdfb3e88f4872995f9a05b6298c1bf3d20fe0@65.108.105.48:19956,112fba64a7e5e27b0cf8f02c634334c957891abf@75.119.146.244:28656,149f9f017344ce9cebb637baa7cab57a28f3a8c3@86.111.48.159:26656,4bfb0d4d945985d2cc92ea4ba3578459b80f1dab@190.2.155.67:33656,577c2f22868fd296a845832626c4fde00e5b92ff@78.159.115.21:38656,13a9209a4d08803a3becac57de8eb02dd51f8f41@65.109.23.114:19956,0adbe1e790b58d19cc53a9839059a95d7d5d7aba@65.109.70.23:19956"
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
