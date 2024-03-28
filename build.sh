#!/bin/bash
CONF=".config"
PROJECTPATH=$(sed -n '1p' $CONF)
PROJECT_CONF="$PROJECTPATH/.config" 
PROJECTNAME=$(sed -n '1p' "$PROJECT_CONF")
VERSION=$(sed -n '3p' "$PROJECT_CONF").$(sed -n '4p' "$PROJECT_CONF")
REPO=$(sed -n '2p' "$PROJECT_CONF")
ARCH=$(sed -n '5p' "$PROJECT_CONF")
PUSH=$(sed -n '6p' "$PROJECT_CONF")
INCREASE=$(sed -n '7p' "$PROJECT_CONF")

green_checkmark="\033[32m\xE2\x9C\x93\033[0m"
red_x="\033[31m\xE2\x9C\x97\033[0m"

if [[ $PUSH = "yes" ]]; 
    then RPUSH="--push" && PUSHSTAT=$green_checkmark; fi
if [[ $PUSH = "no" ]]; 
    then RPUSH="" && PUSHSTAT=$red_x; fi

if [[ $INCREASE = "yes" ]];
    then INCREASESTAT=$green_checkmark; fi
if [[ $INCREASE = "no" ]]; 
    then INCREASESTAT=$red_x; fi

echo "------------- CURRENT SETTINGS -------------"
echo -e "\033[4mProject-Path:\033[0m        \033[3m$PROJECTPATH\033[0m"
echo -e "\033[4mProject:\033[0m             \033[3m$PROJECTNAME\033[0m"
echo -e "\033[4mImage-Name:\033[0m          \033[3m$REPO/$PROJECTNAME:$VERSION\033[0m"
echo -e "\033[4mArch:\033[0m                \033[3m$ARCH\033[0m"
echo -e "\033[4mUpload:\033[0m              \033[3m$PUSHSTAT\033[0m"
echo -e "\033[4mIncrease Subversion:\033[0m \033[3m$INCREASESTAT\033[0m"
echo "--------------------------------------------"






echo docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f "$PROJECTPATH"/dockerfile .
docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f "$PROJECTPATH"/dockerfile .

if [ $? -eq 0 ]; then
    echo "Image build successfull";
    if [[ $INCREASE = "yes" ]]; 
    then sv=$(sed -n '4p' "$PROJECT_CONF");
        svn=$((sv + 1))
        sed -i "4s/.*/$svn/" "$PROJECT_CONF";
    fi
else
    echo "ERROR in build-process"
fi