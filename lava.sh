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
PEERS="37fc77cca6c945d12c6e54166c3b9be2802ad1e6@lava-testnet.nodejumper.io:27656,4bfb0d4d945985d2cc92ea4ba3578459b80f1dab@190.2.155.67:33656,ac7cefeff026e1c616035a49f3b00c78da63c2e9@18.215.128.248:26656,6c988ad39fef48abd5504fda547d561fb8a60c3a@130.185.119.243:33656,2c2353c872b0c5af562c518b1aa48a2649a4c927@65.108.199.62:11656,4f9120f706512162fbe4f39aac78b9924efbec58@65.109.92.235:11036,f9190a58670c07f8202abfd9b5b14187b18d755b@144.76.97.251:27656,f120685de6785d8ee0eadfca42407c6e10593e74@144.76.90.130:32656,6641a193a7004447c1b49b8ffb37a90682ce0fb9@65.108.78.116:13656,c19965fe8a1ea3391d61d09cf589bca0781d29fd@162.19.217.52:26656,0516c4d11552b334a683bdb4410fa22ef7e3f8ba@65.21.239.60:11656,dabe2e77bd6b9278f484b34956750e9470527ef7@178.18.246.118:26656,24a2bb2d06343b0f74ed0a6dc1d409ce0d996451@188.40.98.169:27656,2031e65ee8a13e57d922a14d28d67be0ada21a95@54.194.240.43:26656,c678ae0fd7b754615e55bba2589a86e60fc8d45c@136.243.88.91:7140,a65de5f01394199366c182a18d718c9e3ef7f981@159.148.146.132:26656,cc2b2250b21cd6d23305143a32181e5f6bfc5956@135.181.50.187:26656,0561fed6e88f2167979e379436529861527d859d@65.109.92.148:61256,2b5d760125c90970ce27f4783a5d70a19534ff61@146.19.24.101:26546,fe1998168f5336811a79fbcaf2d5d5a69f2f9f63@65.108.81.145:26656,39309f1ce3d7b6acf9714c749b67c7db6d3f615d@38.242.152.174:26656,9cb975a6676f38577f3888cbc3d7306df3e95f1f@176.120.177.123:26656,5a469a75fb05eddf2d79fb17063cc59e84d0821a@207.180.236.115:34656,0314d53cc790860fb51f36ac656a19789800ce5c@176.103.222.20:26656,14ae45e7f2ff7491cfa686a8fcac7cc095bc38ff@213.239.217.52:39656,28db9a9c200bedbe5d322f7571462f1146ef898e@209.126.2.184:26656,de764d94d3eed3ac15c2151b5576dd24de5bec81@38.242.236.179:26656,57474bd0977b3ed65cf23086b6d1d92bf00d50d0@207.180.236.122:31656,0efa60456219f5b7847ee21439aa8662c0a8e1b6@65.21.195.40:26656,304aaedbaca64664a653884151fb5024cc3b4b20@91.105.97.116:36656,024a0b0a6eae16a2e8aaefcf26b12d2a3b393b28@75.119.155.60:26656,2db2e00432fc950fa2afa03a84288a437fc1c305@2.58.82.212:26656,9a8477637f7944f2537234bbfb6e1559b7805157@195.3.221.13:56656,0a528da95ca8025ef4043b6e73f1e789f4102940@176.103.222.22:26656,90451ff8f47b8f4b077e95837f112135fea14531@207.180.231.123:31656,529675163b5d16838928fe10edce5ef827ff591f@46.4.68.113:25556,6625725632a9343c1d412bc2ec5d76b0cf8289ef@65.21.245.235:26656,3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@3.252.219.158:26656,464e98fa27165f3a13f4173c0ecfbe71ce8f1bf2@167.86.94.71:36656,897fbd850aff33b4d5012d30a8b0ce04225f907f@2.58.82.231:26656,e4c705abed2f76830652799d2eb386a9b876daff@168.119.52.60:26656,151cc6fb6d1a4a4c2f76f7eaf43b9ea80d62ec7b@95.214.55.46:22626,6b1d0465b3e2a32b5328e59eb75c38d88233b56f@80.82.215.19:60656,d3001223151430f204917eb87f86d0bd1e795ebf@161.97.162.6:26656,580d6c9be21f26a713881fc9dcb4ebafcc945eb6@159.65.16.202:26656,c210ed8ecd986a7cc19e87a34c5a2a0f87f1a45c@185.48.24.106:29656,3b3a633e4ad83914a64288dca82f7a7b62536820@65.21.193.112:38656,a76af03d79a90992d135750ab945f79f167d6ee4@65.109.139.182:26656,4f97a7b7d386dc6cc4b4a7239cf76be3c507a1c8@173.212.243.149:26656,fcbe43af6ef40fca686af83e13a8b03d1a6046e6@135.181.178.53:56656,95a490b4cde4c5311f7d58c3e47ee41fa039ddf4@144.76.27.79:60756"
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
