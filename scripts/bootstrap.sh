#!/bin/bash -e

tabs 4
clear
readonly VENV_DIR=$HOME/.venv

install_core() {
    local ppas="ppa.list"
    for ppa in $(cat $ppas)
    do
        sudo add-apt-repository -y $ppa
    done
    sudo apt-get update
    sudo apt-get install -y byobu htop vim fonts-inconsolata openssh-server gtk2-engines-murrine \
        libcurl4-openssl-dev python-dev python3-dev build-essential cmake git linux-headers-generic \
        Trimmomatic julia r-base vienna-rna \
        libopenblas-base libopenblas-dev gfortran g++ python-pip \
        samtools bedtools libpng-dev libjpeg8-dev libfreetype6-dev \
        libatlas3gf-base libatlas-dev python3-venv libxml2-dev libxslt-dev
    sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
    sudo update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3
    sudo update-alternatives --set liblapack.so.3 /usr/lib/openblas-base/liblapack.so.3
}

install_google() {
    local base_url="https://dl.google.com/linux/direct"
        case `uname -i` in
            i386|i486|i586|i686)
            wget $base_url/google-chrome-beta_current_i386.deb
            wget $base_url/google-talkplugin_current_i386.deb
            ;;
        x86_64)
            wget $base_url/google-chrome-beta_current_amd64.deb
            wget $base_url/google-talkplugin_current_amd64.deb
            ;;
    esac
    sudo dpkg -i google*.deb
    sudo apt-get install -fy
    rm google*.deb
}

setup_env() {
    local pydata="pydata.list"
    
    if [ -d $VENV_DIR/pydata3 ]
    then
        rm -rf $VENV_DIR/pydata3
    fi

    pyvenv $VENV_DIR/pydata3
    source $VENV_DIR/pydata3/bin/activate
    for package in $(cat $pydata)
    do
        pip install $package
    done
    deactivate
}

setup_i3() {
    local dir="$(cd "$(dirnaame ${BASH_SOURCE[0]})" && pwd)"
    local wrapper="i3-wrapper.sh"
    local locker="lock.sh"
    sudo sh -c echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" >> /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install --allow-unauthenticated sur5r-keyring
    sudo apt-get update
    sudo apt-get install i3 compton imagemagick scrot nitrogen
    # TODO: update-alternatives for d3menu
    cd $dir
    if [ ! -d "$HOME/.i3" ]
    then
        ln -s ../$dir $HOME/.i3
    fi
    if [ ! -e "$wrapper" ]
    then
        sudo cp $wrapper /usr/bin
    fi
    if [ ! -e "$locker" ]
    then
        sudo cp $locker /usr/bin
    fi
    cd -
}

main() {
    install_core
    install_google
    setup_env
    setup_i3
}

main
