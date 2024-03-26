#!/bin/bash


if [ ! -f ".config" ]; then
    touch ".config"
    echo -e "PROJECTNAME\nREPOSITORY\nVERSION\nSUBVERSION\nARCH\nPUSH\nPROJECTPATH\n" > ".config"
fi


ende()
{
    exit
}


menue()
{

CONF=".config" 
PROJECTPATH=$(sed -n '7p' $CONF)   
PROJECTNAME=$(sed -n '1p' $CONF)
VERSION=$(sed -n '3p' $CONF).$(sed -n '4p' $CONF)
REPO=$(sed -n '2p' $CONF)
ARCH=$(sed -n '5p' $CONF)
PUSH=$(sed -n '6p' $CONF)

green_checkmark="\033[32m\xE2\x9C\x93\033[0m"
red_x="\033[31m\xE2\x9C\x97\033[0m"

if [[ $PUSH = "yes" ]];
    then PUSHSTAT=$green_checkmark; fi
if [[ $PUSH = "no" ]]; 
    then PUSHSTAT=$red_x; fi
clear
echo "------------- CURRENT SETTINGS -------------"
echo -e "\033[4mProject-Path:\033[0m     \033[3m$PROJECTPATH\033[0m"
echo -e "\033[4mProject:\033[0m          \033[3m$PROJECTNAME\033[0m"
echo -e "\033[4mImage-Name:\033[0m       \033[3m$REPO/$PROJECTNAME:$VERSION\033[0m"
echo -e "\033[4mArch:\033[0m             \033[3m$ARCH\033[0m"
echo -e "\033[4mUpload:\033[0m           \033[3m$PUSHSTAT\033[0m"
echo "--------------------------------------------"
echo ""
echo "b) Build the Image with current settings"
echo "e) Edit settings"
echo "s) Setup Docker and BuildX-PlugIn"
echo "x) Exit Image-Builder"
echo ""
read -p 'Your choice: ' menue_wahl

    case "$menue_wahl" in
        b)
            bash build.sh
            menue
            ;;
            #############################################
        e)
            clear
            bash edit.sh
            ;;
            #############################################
        s)
            clear
            bash setup.sh
            ;;
            #############################################
        x|X)
		    clear
		    ende
		    ;;
		    #############################################
	    *)
		    echo "Key not valid"
            read -p "Try again..." WEITER
            clear
            menue
		    ;;
		    #############################################
    esac

}

#####################################################################

clear
menue