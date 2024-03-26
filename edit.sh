#!/bin/bash


##############################################################
ende()
{
    exit
}
##############################################################

menue()
{
CONF=".config"
PROJECTPATH=$(sed -n '7p' $CONF) 
PROJECTNAME=$(sed -n '1p' $CONF)
VERSION=$(sed -n '3p' $CONF)
SUBVERSION=$(sed -n '4p' $CONF)
REPO=$(sed -n '2p' $CONF)
ARCH=$(sed -n '5p' $CONF)
PUSH=$(sed -n '6p' $CONF)

green_checkmark="\033[32m\xE2\x9C\x93\033[0m"
red_x="\033[31m\xE2\x9C\x97\033[0m"

if [[ $PUSH = "yes" ]];
    then PUSHSTAT=$green_checkmark; fi
if [[ $PUSH = "no" ]]; 
    then PUSHSTAT=$red_x; fi

#clear
echo "------------- CURRENT SETTINGS -------------"
echo -e "\033[4mProject-Path:\033[0m     \033[3m$PROJECTPATH\033[0m"
echo -e "\033[4mProject:\033[0m          \033[3m$PROJECTNAME\033[0m"
echo -e "\033[4mImage-Name:\033[0m       \033[3m$REPO/$PROJECTNAME:$VERSION.$SUBVERSION\033[0m"
echo -e "\033[4mArch:\033[0m             \033[3m$ARCH\033[0m"
echo -e "\033[4mUpload:\033[0m           \033[3m$PUSHSTAT\033[0m"
echo "--------------------------------------------"
echo ""
echo "b) Back to Build-Menue"
echo ""
echo "f) Project-Path"
echo "p) Project"
echo "r) Docker-Registy"
echo "m) Main-Version"
echo "s) Start of Sub-Version"
echo "a) Arch"
echo "u) Upload to Registry (yes/no)"
echo "x) Exit Image-Builder"
echo ""
read -p "Edit: " menue_wahl

    case "$menue_wahl" in
        f)
            clear
            echo "Current Project-Path: $PROJECTPATH" 
            echo "Change to: "
            
            folder=(projects/*)
            #ordner=( "${ordner[@]%/}" )

            PS3="Please chose the Project-Directory (or 'q' to quit): "
            select foldername in "${folder[@]}" "quit"; do
                if [ "$foldername" = "quit" ]; then
                    break
                fi
                if [ -n "$foldername" ]; then
                    echo "Change Project-Directory to '$foldername'"
                    sed -i "7s%.*%$foldername%" "$CONF"
                    break
                else
                    echo "Not valid. Try again..."
                fi
            done
            menue
            ;;
        p)
            clear
            echo "Current Project: $PROJECTNAME" 
            echo "Change to: "
            read NEW_PROJECTNAME
            sed -i "1s/.*/$NEW_PROJECTNAME/" "$CONF"
            menue
            ;;
            #############################################
        r)
            clear
            echo "Current Repository: $REPO" 
            echo "Change to: "
            read NEW_REPO
            sed -i "2s/.*/$NEW_REPO/" "$CONF"
            menue
            ;;
            #############################################
        m)
            clear
            echo "Current Main-Version: $VERSION" 
            echo "Change to: "
            read NEW_VERSION
            sed -i "3s/.*/$NEW_VERSION/" "$CONF"
            menue
            ;;
            #############################################
        s)
            clear
            echo "Current Sub-Version: $SUBVERSION" 
            echo "Change to: "
            read NEW_SUBVERSION
            sed -i "4s/.*/$NEW_SUBVERSION/" "$CONF"
            menue
            ;;
            #############################################
        a)
            #clear

            options=(
                1 "386" off
                2 "amd64" off
                3 "aarch64" off
            )

            selection=$(dialog --checklist "Arch to build:" 10 40 3 "${options[@]}" 2>&1 >/dev/tty)

            if [ $? -ne 0 ]; then
                echo "Canceled."
                exit 1
            fi

            echo "Build Archs:"
            selected_options=""
            for choice in $selection; do
                case $choice in
                    1) selected_options+="linux/386,";;
                    2) selected_options+="linux/amd64,";;
                    3) selected_options+="linux/aarch64,";;
                esac
            done

            selected_options=${selected_options%,}
            sed -i "5s%.*%$selected_options%" "$CONF"
            menue
            ;;
            #############################################
        u)
            clear
            echo "Current status of Push: ($PUSH)" 
            echo "Change to: "
            read NEW_PUSH
            sed -i "6s/.*/$NEW_PUSH/" "$CONF"
            menue
            ;;
            #############################################
        b)
		    clear
		    bash start.sh
		    ;;
		    #############################################
        x|X)
		    clear
		    ende
		    ;;
		    #############################################
	    *)
		    echo "Key not valid"
            read -p "Try again... " WEITER
            clear
            menue
		    ;;
		    #############################################
    esac

}

#####################################################################

clear
menue
