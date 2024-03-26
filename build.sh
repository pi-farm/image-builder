#!/bin/bash
CONF=".config" 
PROJECTPATH=$(sed -n '7p' $CONF)   
PROJECTNAME=$(sed -n '1p' $CONF)
VERSION=$(sed -n '3p' $CONF).$(sed -n '4p' $CONF)
REPO=$(sed -n '2p' $CONF)
ARCH=$(sed -n '5p' $CONF)
PUSH=$(sed -n '6p' $CONF)

echo "------------- CURRENT SETTINGS -------------"
echo -e "\033[4mProject-Path:\033[0m     \033[3m$PROJECTPATH\033[0m"
echo -e "\033[4mProject:\033[0m          \033[3m$PROJECTNAME\033[0m"
echo -e "\033[4mImage-Name:\033[0m       \033[3m$REPO/$PROJECTNAME:$VERSION\033[0m"
echo -e "\033[4mArch:\033[0m             \033[3m$ARCH\033[0m"
echo -e "\033[4mUpload:\033[0m           \033[3m$PUSHSTAT\033[0m"
echo "--------------------------------------------"

green_checkmark="\033[32m\xE2\x9C\x93\033[0m"
red_x="\033[31m\xE2\x9C\x97\033[0m"


if [[ $1 = p ]]; 
    then PUSH="--push " && PUSHSTAT=$green_checkmark; fi
if [[ $1 = n ]]; 
    then PUSH="" && PUSHSTAT=$red_x; fi

docker buildx build --platform $ARCH -t $REPO/$PROJECTNAME:$VERSION $PUSH $PROJECTPATH.