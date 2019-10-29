#!/bin/bash
set -e

# This script has been tested on MacOS 10.14.6 Mojave
# Make sure you have GO & git installed before running the script

#Color to the people
CYAN='\x1B[0;36m'
GREEN='\x1B[0;32m'
NC='\x1B[0m'

BINARYVER='sf2019-1'
CONFIGVER='sf2019'

echo -e
echo -e "${GREEN}--> Installing Elrond-Go Node...${NC}"
echo -e

#Prerequisites
echo -e
echo -e "${GREEN}--> Making sure you have all needed prerequisites...${NC}"
echo -e

bash _prerequisite.sh

#Let's handle the paths
export GOPATH=$HOME/go

#If repos are present and you run install again this will clean up for you :D
if [ -d "$GOPATH/src/github.com/ElrondNetwork/elrond-go" ]; then echo -e "${RED}--> Repos present. Please run update.sh script...${NC}"; echo -e; exit; fi
mkdir -p $GOPATH/src/github.com/ElrondNetwork/elrond-go
cd $GOPATH/src/github.com/ElrondNetwork/elrond-go


echo -e
echo -e "${GREEN}--> Get ${CYAN}elrond-go${GREEN} assets & clone ${CYAN}elrond-config${GREEN} repo...${NC}"
echo -e

#Clone the elrong-go & elrong-config repos
curl -s https://api.github.com/repos/ElrondNetwork/elrond-go/releases/tags/$BINARYVER | grep "browser_download_url.*mac\|browser_download_url.*dylib" | cut -d : -f 2,3 | tr -d \" | wget -qi -
mv node.mac node
mv keygenerator.mac keygenerator
chmod 777 node
chmod 777 keygenerator
cd ..
git clone https://github.com/ElrondNetwork/elrond-config
cd elrond-config && git checkout --force $CONFIGVER

#Create the working folder & getting current testnet configs
mkdir -p $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config
cp *.* $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config

#Copying the node & .dylib files from the elrond-go repo
cd $GOPATH/src/github.com/ElrondNetwork/elrond-go
cp node $GOPATH/src/github.com/ElrondNetwork/elrond-go-node
sudo cp libwasmer_runtime_c_api.dylib /usr/local/lib

#Choose a custom node name... or leave it at default
echo -e
echo -e "${GREEN}--> Build ready. Time to choose a node name...${NC}"
echo -e
cd $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config
CURRENT=$(sed -e 's#.*-\(\)#\1#' <<< "$CONFIGVER")
read -p "Choose a custom name (default community-validator-$CURRENT): " NODE_NAME
if [ "$NODE_NAME" = "" ]
then
    NODE_NAME="community-validator-$CURRENT"
fi
sed -i -e 's/NodeDisplayName = ""/NodeDisplayName = "'$NODE_NAME'"/' $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config/prefs.toml


#Build Key Generator and create unique node keys
echo -e
echo -e "${GREEN}--> Building the Key Generator & creating unique node pems...${NC}"
echo -e
cd $GOPATH/src/github.com/ElrondNetwork/elrond-go
./keygenerator

#Copy the credentials for the node
cp -n initialBalancesSk.pem $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config
cp -n initialNodesSk.pem $GOPATH/src/github.com/ElrondNetwork/elrond-go-node/config
        
echo -e "${GREEN}Everything in place. Go ahead and run the node ! Have fun!${NC}"
sleep 2

echo -e
echo -e "${GREEN}Options for starting your Elrond Node:${NC}"
echo -e "${CYAN}front${GREEN} - Will start your node in the foreground${NC}"
echo -e "${CYAN}screen${GREEN} - Will start your node in the backround using the screen app${NC}"
echo -e "${CYAN}ENTER${GREEN} - Will exit to the command line without starting your node (in case you need to add previously generated pems)${NC}"
echo -e
echo -e

read -p "How do you want to start your node (front|screen) : " START

case $START in
   front)
        cd $HOME/elrond-go-scripts/macos/start_scripts/ && ./start.sh
        ;;
    screen)
        cd $HOME/elrond-go-scripts/macos/start_scripts/ && ./start_screen.sh
        ;;
    *)
        echo "Ok ! Have it your way then..."
        ;;
esac