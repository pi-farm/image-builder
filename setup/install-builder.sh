#!/bin/bash
apt-get update
apt-get install -y docker-buildx-plugin
#apt-get install binfmt-support qemu-user-static -y

#apt-get install jq -y
#rm -r ~/.docker/cli-plugins
#mkdir -p ~/.docker/cli-plugins
#BUILDX_URL=$(curl https://api.github.com/repos/docker/buildx/releases/latest | jq -r .assets[].browser_download_url | grep arm64)
#wget $BUILDX_URL -O ~/.docker/cli-plugins/docker-buildx
#chmod +x ~/.docker/cli-plugins/docker-buildx