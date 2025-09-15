#!/bin/bash

ende()
{
    exit
}


DOCKERVERSION=$(docker --version)
BUILDXVERSION=$(docker buildx version)
BUILDERINFO=$(docker buildx inspect --bootstrap | grep -E 'Name:|BuildKit version:|Status:')


menue()
{
echo "------------- DOCKER SETTINGS -------------"
echo -e "\033[4mDocker Version:\033[0m        \033[3m$DOCKERVERSION\033[0m"
echo -e "\033[4mBuildX Version:\033[0m        \033[3m$BUILDXVERSION\033[0m"
echo -e "\033[4mBuilder-Info:\033[0m          \033[3m$BUILDERINFO\033[0m"
echo "--------------------------------------------"
echo ""
echo "b) Back to Build-Menue"
echo ""
echo "d) Install Docker Engine"
echo "p) Install BuildX-PlugIn"
echo "s) Setup BuildX-Builder"
echo "a) Active BuildX-Builder"
echo "x) Exit Image-Builder"
echo ""
read -p 'Your choice: ' -n 1 menue_wahl

  case "$menue_wahl" in
    b)
      bash start.sh
      menue
      ;;
    #############################################
    d)
      sudo bash setup/install-docker.sh
      clear
      menue
      ;;
    #############################################
    p)
      sudo bash setup/install-builder.sh
      clear
      menue
      ;;
    #############################################
    s)
      bash setup/setup-builder.sh
      clear
      menue
      ;;
    #############################################
    a)
      bash setup/show-active-builder.sh
      echo ""
 #     clear
      menue
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