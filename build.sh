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
LATEST=$(sed -n '8p' "$PROJECT_CONF")
BUILDCACHE=$(sed -n '9p' "$PROJECT_CONF")

green_checkmark="\033[32m\xE2\x9C\x93\033[0m"
red_x="\033[31m\xE2\x9C\x97\033[0m"

if [[ $PUSH = "yes" ]]; 
    then RPUSH="--push" && PUSHSTAT=$green_checkmark; fi
if [[ $PUSH = "no" ]]; 
    then RPUSH="--load" && PUSHSTAT=$red_x; fi

if [[ $INCREASE = "yes" ]];
    then INCREASESTAT=$green_checkmark; fi
if [[ $INCREASE = "no" ]]; 
    then INCREASESTAT=$red_x; fi

if [[ $LATEST = "yes" ]];
    then LATESTSTAT=$green_checkmark; fi
if [[ $LATEST = "no" ]]; 
    then LATESTSTAT=$red_x; fi

if [[ $BUILDCACHE = "yes" ]];
    then BUILDCACHESTAT=$green_checkmark; fi
if [[ $BUILDCACHE = "no" ]]; 
    then BUILDCACHESTAT=$red_x; fi

echo ""
echo "------------- CURRENT SETTINGS -------------"
echo -e "\033[4mProject-Path:\033[0m        \033[3m$PROJECTPATH\033[0m"
echo -e "\033[4mProject:\033[0m             \033[3m$PROJECTNAME\033[0m"
echo -e "\033[4mImage-Name:\033[0m          \033[3m$REPO/$PROJECTNAME:$VERSION\033[0m"
echo -e "\033[4mArch:\033[0m                \033[3m$ARCH\033[0m"
echo -e "\033[4mUpload:\033[0m              \033[3m$PUSHSTAT\033[0m"
echo -e "\033[4mIncrease Subversion:\033[0m \033[3m$INCREASESTAT\033[0m"
echo -e "\033[4mTag as 'latest':\033[0m     \033[3m$LATESTSTAT\033[0m"
echo -e "\033[4mUse Build-Cache:\033[0m     \033[3m$BUILDCACHESTAT\033[0m"
echo "--------------------------------------------"
echo ""

cd $PROJECTPATH

if [[ $PUSH = "yes" ]]; then 
    if [[ $LATEST = "yes" ]]; then
        if [[ $BUILDCACHE = "yes" ]]; then
            echo docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .
            DOCKER_COMMAND="docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .";
        fi
        if [[ $BUILDCACHE = "no" ]]; then
            echo docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .
            echo "test"
            DOCKER_COMMAND="docker buildx build --no-cache --platform linux/amd64 --file Dockerfile --output type=local,dest=./output/amd64 -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest --no-cache --platform linux/arm64 --file Dockerfile.aarch64 --output type=local,dest=./output/arm64 -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest --push .";

            #DOCKER_COMMAND="docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .";
        fi
    fi
    if [[ $LATEST = "no" ]]; then
        if [[ $BUILDCACHE = "yes" ]]; then
            echo docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .
            DOCKER_COMMAND="docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .";
        fi
        if [[ $BUILDCACHE = "no" ]]; then
            echo docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .
            DOCKER_COMMAND="docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .";
        fi
    fi
fi
if [[ $PUSH = "no" ]]; then
    if [[ $LATEST = "yes" ]]; then
        if [[ $BUILDCACHE = "yes" ]]; then
            echo docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .
            DOCKER_COMMAND="docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .";
        fi
        if [[ $BUILDCACHE = "no" ]]; then
            echo docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .
            DOCKER_COMMAND="docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -t "$REPO"/"$PROJECTNAME":latest -f Dockerfile .";
        fi
    fi
    if [[ $LATEST = "no" ]]; then
        if [[ $BUILDCACHE = "yes" ]]; then
            echo docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .
            DOCKER_COMMAND="docker buildx build --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .";
        fi
        if [[ $BUILDCACHE = "no" ]]; then
            echo docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .
            DOCKER_COMMAND="docker buildx build --no-cache --platform="$ARCH" "$RPUSH" -t "$REPO"/"$PROJECTNAME":"$VERSION" -f Dockerfile .";
        fi
    fi
fi
$DOCKER_COMMAND
EXIT_CODE=$?
cd ../../    
if [ $EXIT_CODE -eq 0 ]; then
    echo "Image build successfull"
    if [[ $INCREASE = "yes" ]]; then
        sv=$(sed -n '4p' "$PROJECT_CONF")
        svn=$((sv + 1))
        sed -i "4s/.*/$svn/" "$PROJECT_CONF"
    fi
else
    echo "ERROR in build-process: $EXIT_CODE"
fi
