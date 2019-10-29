#!/bin/bash
#Handle some paths
export GOPATH=$HOME/go

echo -e "${GREEN}Now launching node...${NC}"
sleep 2
cd $HOME/go/src/github.com/ElrondNetwork/elrond-go-node/ && screen -m -d -S validator bash -c './node;'
