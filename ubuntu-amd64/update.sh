#!/bin/bash

BINARYVER='sf2019-1'
CONFIGVER='sf2019'

#Color to the people
RED='\x1B[0;31m'
CYAN='\x1B[0;36m'
GREEN='\x1B[0;32m'
NC='\x1B[0m'

#Handle some paths
export GOPATH=$HOME/go

#Stop the currently running node binary
if (screen -ls | grep testnet -c); then screen -X -S testnet quit; else tmux kill-session -t testnet; fi

#Refetch elrond-go assets
cd $GOPATH/src/github.com/ElrondNetwork/elrond-go
curl -s https://api.github.com/repos/ElrondNetwork/elrond-go/releases/tags/$BINARYVER | grep "browser_download_url.*linux\|browser_download_url.*so" | cut -d : -f 2,3 | tr -d \" | wget -qi -
mv node.linux node
mv keygenerator.linux keygenerator
chmod 777 node
chmod 777 keygenerator
cp node $GOPATH/src/github.com/ElrondNetwork/elrond-go-node
sudo cp libwasmer_runtime_c_api.so /usr/lib

#Refetch and rebuild elrond-config
cd $HOME/go/src/github.com/ElrondNetwork/elrond-config
git fetch
git checkout --force $CONFIGVER
git pull
cp *.* $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config

#Choose a custom node name... or leave it at default
echo -e
echo -e "${GREEN}--> Build ready. Time to choose a node name...${NC}"
echo -e

cd $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config
CURRENT=$(sed -e 's#.*-\(\)#\1#' <<< "$CONFIGVER")

#Node DB & Logs Cleanup
cd $GOPATH/src/github.com/ElrondNetwork/elrond-go-node

read -p "Do you want to remove the current Node DB? (default yes): " rem_db
if [ "$rem_db" != "no" ]
then
  sudo rm -rf db
fi

sudo rm -rf logs
sudo rm -rf stats


echo -e
echo -e "${GREEN}Options for starting your Elrond Node:${NC}"
echo -e "${CYAN}front${GREEN} - Will start your node in the foreground${NC}"
echo -e "${CYAN}screen${GREEN} - Will start your node in the backround using the screen app${NC}"
echo -e "${CYAN}tmux${GREEN} - Will start your node in the backround using the tmux app${NC}"
echo -e "${CYAN}ENTER${GREEN} - Will exit to the command line without starting your node (in case you need to add previously generated pems)${NC}"
echo -e
echo -e

location=$(find $HOME -xdev 2>/dev/null -name "elrond-go-scripts")

read -p "How do you want to start your node (front|screen|tmux) : " START

case $START in
     front)
        cd $location/ubuntu-amd64/start_scripts/ && ./start.sh
        ;;
        
     screen)
        cd $location/ubuntu-amd64/start_scripts/ && ./start_screen.sh
        ;;
     
     tmux)
        cd $location/ubuntu-amd64/start_scripts/ && ./start_tmux.sh
        ;;
     
     *)
        echo "Ok ! Have it your way then..."
        ;;
esac
