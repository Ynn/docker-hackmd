#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo docker pull hackmdio/hackmd
sudo docker rmi "nnynn/hackmd:latest"
(cd $DIR/hackmd && sudo docker build -t "nnynn/hackmd:latest" .)
sudo docker images | grep hackmd
