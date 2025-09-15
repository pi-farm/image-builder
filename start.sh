#!/bin/bash


if [ ! -f ".config" ]; then
    touch ".config"
    echo -e "PROJECTPATH" > ".config"
fi

PACKAGE="dialog"
if command -v "$PACKAGE" &> /dev/null; then
    true
else
    echo "$PACKAGE is not installed, please install it first."
fi

ende()
{
    exit
}


menue()
{

CONF=".config"
PROJECTPATH=$(sed -n '1p' "$CONF")

if [ ! -f "$PROJECTPATH/.config" ]; then
    touch "$PROJECTPATH/.config"
    echo -e "PROJECTNAME\nREPOSITORY\nVERSION\nSUBVERSION\nARCH\nPUSH\nINCREASE" > "$PROJECTPATH/.config"
fi

PROJECT_CONF="$PROJECTPATH/.config" 

PROJECTNAME=$(sed -n '1p' "$PROJECT_CONF")
VERSION=$(sed -n '3p' "$PROJECT_CONF").$(sed -n '4p' "$PROJECT_CONF")
REPO=$(sed -n '2p' "$PROJECT_CONF")
ARCH=$(sed -n '5p' "$PROJECT_CONF")
PUSH=$(sed -n '6p' "$PROJECT_CONF")
INCREASE=$(sed -n '7p' "$PROJECT_CONF")
LATEST=$(sed -n '8p' "$PROJECT_CONF")
BUILDCACHE=$(sed -n '9p' "$PROJECT_CONF")
DF386=$(sed -n '10p' "$PROJECT_CONF")
DFAMD64=$(sed -n '11p' "$PROJECT_CONF")
DFARM64=$(sed -n '12p' "$PROJECT_CONF")

green_checkmark="\033[32m\xE2\x9C\x93\033[0m"
red_x="\033[31m\xE2\x9C\x97\033[0m"

if [[ $PUSH = "yes" ]];
    then PUSHSTAT=$green_checkmark; fi
if [[ $PUSH = "no" ]]; 
    then PUSHSTAT=$red_x; fi

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

#clear
echo ""
echo "-------------------- CURRENT SETTINGS --------------------"
echo ""
echo -e "\033[4mProject-Path:\033[0m        \033[3m$PROJECTPATH\033[0m"
echo -e "\033[4mProject:\033[0m             \033[3m$PROJECTNAME\033[0m"
echo -e "\033[4mImage-Name:\033[0m          \033[3m$REPO/$PROJECTNAME:$VERSION\033[0m"
echo -e "\033[4mArch:\033[0m                \033[3m$ARCH\033[0m"
echo -e "\033[4mUpload:\033[0m              \033[3m$PUSHSTAT\033[0m"
echo -e "\033[4mIncrease Subversion:\033[0m \033[3m$INCREASESTAT\033[0m"
echo -e "\033[4mTag as 'latest':\033[0m     \033[3m$LATESTSTAT\033[0m"
echo -e "\033[4mUse Build-Cache:\033[0m     \033[3m$BUILDCACHESTAT\033[0m"
echo "----------------------------------------------------------"
echo ""
echo "b) Build the Image with current settings"
echo "m) Build with Docker manifest with different Dockerfiles for dif. architectures"
echo
echo "n) Create new Project"
echo "g) Create new Project from Git-URL"
echo "c) Change to another Project"
echo "r) Rename a Project"
echo "d) Remove Project"
echo "e) Edit Project-settings"
echo ""
echo "s) Setup Docker and BuildX-PlugIn"
echo "x) Exit Image-Builder"
echo ""
read -p 'Your choice: ' -n 1 menue_wahl

    case "$menue_wahl" in
        c)
            clear
            echo "Current Project-Path: $PROJECTPATH" 
            echo "Change to: "
            
            folder=(projects/*)
            PS3="Please chose the Project-Directory (or 'q' to quit): "
            select foldername in "${folder[@]}" "quit"; do
                if [ "$foldername" = "quit" ]; then
                    break
                fi
                if [ -n "$foldername" ]; then
                    clear
                    echo "Change Project-Directory to '$foldername'"
                    sed -i "1s%.*%$foldername%" "$CONF"
                    break
                else
                    echo "Not valid. Try again..."
                fi
            done
            menue
            ;;
            #############################################
        n) 
            clear
            read -p 'Project-Name: ' NEWPROJECT 
            mkdir projects/$NEWPROJECT
            touch projects/$NEWPROJECT/.config
            echo -e "$NEWPROJECT\nREPOSITORY\nVERSION\nSUBVERSION\nARCH\nPUSH\nINCREASE\nLATEST\nBUILDCACHE" > "projects/$NEWPROJECT/.config"
            sed -i "1s%.*%projects/$NEWPROJECT%" "$CONF"
            menue
            ;;
            #############################################
        g) 
            clear
            read -p 'Project-Name: ' NEWPROJECT
            read -p 'Git-URL: ' GITURL
            mkdir projects/$NEWPROJECT
            git clone $GITURL projects/$NEWPROJECT
            touch projects/$NEWPROJECT/.config
            echo -e "$NEWPROJECT\nREPOSITORY\nVERSION\nSUBVERSION\nARCH\nPUSH\nINCREASE\nLATEST\nBUILDCACHE" > "projects/$NEWPROJECT/.config"
            sed -i "1s%.*%projects/$NEWPROJECT%" "$CONF"
            menue
            ;;
            #############################################
        r) 
            clear 
            echo "Select the Project to rename: "
            
            folder=(projects/*)
            PS3="Please chose the Project-Directory: "
            select foldername in "${folder[@]}" "quit"; do
                if [ "$foldername" = "quit" ]; then
                    break
                fi
                if [ "$foldername" = "$(sed -n '1p' $CONF)" ]; then
                    echo "Renaming not possible, Project is active. Please change to another Project first."
                    break
                fi
                if [ -n "$foldername" ]; then
                    read -p 'New Project-Name: ' NEWPROJECT
                    echo "Renaming to : '$NEWPROJECT'"
                    mv $foldername projects/$NEWPROJECT
                    sed -i "1s%.*%$NEWPROJECT%" "projects/$NEWPROJECT/$CONF"
                    clear
                    echo "Renaming succuessfull..."
                    break
                else
                    echo "Not valid. Try again..."
                fi
            done
            menue
            ;;
            #############################################
        d) 
            clear 
            echo "Select the Project to delete: "
            
            folder=(projects/*)
            PS3="Please chose the Project-Directory: "
            select foldername in "${folder[@]}" "quit"; do
                if [ "$foldername" = "quit" ]; then
                    break
                fi
                if [ "$foldername" = "$(sed -n '1p' $CONF)" ]; then
                    echo "Delete not possible, Project is active. Please change to another Project first."
                    break
                fi
                if [ -n "$foldername" ]; then
                    echo "Deleting Project-Directory: '$foldername'"
                    rm -r $foldername
                    break
                else
                    echo "Not valid. Try again..."
                fi
            done
            menue
            ;;
            #############################################
        b)
            bash build.sh
            menue
            ;;
            #############################################
        m)
            source ./manifest-build.sh
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
