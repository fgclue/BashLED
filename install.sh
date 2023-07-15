#!/bin/bash

clear
echo "  #####################"
echo "  # BashLED Installer #"
echo "  #####################"
echo ""
echo "==> Detecting Package Manager..."
declare -A osInfo;
osInfo[/etc/redhat-release]="yum install"
osInfo[/etc/arch-release]="pacman -Sy"
osInfo[/etc/SuSE-release]="zypper install"
osInfo[/etc/debian_version]="apt-get install"
osInfo[/etc/alpine-release]="apk add" 

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        echo "=> Package manager: ${osInfo[$f]}"
        if [[ ${osInfo[$f]} == "" ]]
        then
          echo "=> No package manager detected."
        fi
    fi
done

echo "==> Checking for sudo..."
if [[ $EUID -ne 0 ]]
then
  echo "You are running the installer as a normal user. Please run as root."
  exit
fi
echo "==> Checking for git..."
echo "==> Checking for meson..."
if [[ $(whereis git | grep / | wc -m) == 0 ]]
then
  echo "Git is not installed. You need to install git from your package manager."
  exit
fi
if [[ $(whereis meson | grep / | wc -m) == 0 ]]
then
  echo "Meson is not installed. You need to install Meson from your package manager."
  exit
fi

echo "==> Checking for mpv..."
if [[ $(whereis mpv | grep / | wc -m) == 0 ]]
then
  echo "=> mpv not found."
  read -p "Do you want to install mpv? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    read -p "Install mpv from source? (y/N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo "=> Installing mpv..."
      cd /tmp/
      echo "=> Downloading source code..."
      git clone https://github.com/mpv-player/mpv/
      echo "=> Compiling..."
      meson setup build
      meson compile -C build
      meson install -C build
      echo "==> Done! You may now run the installer again to install BashLED."
      exit
    else
      echo
      echo "==> Trying to install mpv..."
      for f in ${!osInfo[@]}
      do
      if [[ -f $f ]];then
        echo P ${osInfo[$f]}
        installcmd="${osInfo[$f]} mpv"
        eval $installcmd
        echo "Done! You may now run the installer again to install BashLED."
        exit
      fi
      done
    fi
  else
    exit
  fi

fi
