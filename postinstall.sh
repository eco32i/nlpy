#!/bin/bash

# Ubuntu GNOME postinstall setup script.

tabs 4
clear

# Setup build environment
#
sudo apt-get install -y byobu htop vim fonts-inconsolata openssh-server gtk2-engines-murrine \
    libcurl4-openssl-dev python-dev python3-dev build-essential cmake linux-headers-generic git 


# Install Google chrome and talkplugin
#
case `uname -i` in
    i386|i486|i586|i686)
        wget https://dl.google.com/linux/direct/google-chrome-beta_current_i386.deb
        wget https://dl.google.com/linux/direct/google-talkplugin_current_i386.deb
        ;;
    x86_64)
        wget https://dl.google.com/linux/direct/google-chrome-beta_current_amd64.deb
        wget
        https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
        ;;
esac
sudo dpkg -i google*.deb
sudo apt-get install -fy
rm google*.deb

# Add xorg-edgers ppa
#
sudo add-apt-repository -y ppa:xorg-edgers/ppa

# Add Gnome3 and Gnome3 staging PPAs
#
sudo add-apt-repository -y ppa:gnome3-team/gnome3
sudo add-apt-repository -y ppa:gnome3-team/gnome3-staging

# Add Yorba PPA (for shotwell and Geary)
#
sudo add-apt-repository -y ppa:yorba/ppa

sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

