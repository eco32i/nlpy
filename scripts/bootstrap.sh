#!/bin/bash -e

tabs 4
clear
readonly VENV_DIR=$HOME/.venv

install_core() {
    sudo apt update
    sudo apt install -y git buikd-essential byobu htop vim vim-nox \
        fonts-inconsolata openssh-server gtk2-engines-murrine \
        libcurl4-openssl-dev python3-dev build-essential cmake git linux-headers-generic \
        trimmomatic r-base libhdf5-dev hdf5-tools curl \
        libopenblas0 libopenblas-dev gfortran g++ python3-pip fonts-cantarell \
        samtools bedtools libpng-dev libjpeg8-dev libfreetype6-dev libxft-dev \
        tsocks libhdf5-dev libatlas3-base libatlas-base-dev python3-venv libxml2-dev libxslt1-dev
    sudo apt upgrade -y && sudo apt dist-upgrade -y
}

install_google() {
    local base_url="https://dl.google.com/linux/direct"
        case `uname -i` in
            i386|i486|i586|i686)
            wget $base_url/google-chrome-beta_current_i386.deb
            ;;
        x86_64)
            wget $base_url/google-chrome-beta_current_amd64.deb
            ;;
    esac
    sudo dpkg -i google*.deb
    sudo apt install -fy
    rm google*.deb
}

setup_i3() {
    local dir="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"
    local wrapper="i3-wrapper.sh"
    local locker="lock.sh"
    #/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2022.02.17_all.deb keyring.deb SHA256:52053550c4ecb4e97c48900c61b2df4ec50728249d054190e8a0925addb12fc6
    #sudo dpkg -i ./keyring.deb
    #rm -rf ./keyring.deb
    #echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
    curl https://baltocdn.com/i3-window-manager/signing.asc | sudo apt-key add -
    sudo apt install apt-transport-https --yes
    echo "deb https://baltocdn.com/i3-window-manager/i3/i3-autobuild-ubuntu/ all main" | sudo tee /etc/apt/sources.list.d/i3-autobuild.list
    sudo apt update
    sudo apt install i3 xautolock imagemagick scrot nitrogen -y
    old_dir=$(pwd)
    cd $dir && cd ..
    if [ ! -d "$HOME/.i3" ]
    then
        ln -s conf/.i3 $HOME/.i3
    fi
    if [ ! -e "/bin/$wrapper" ]
    then
        sudo cp utils/$wrapper /bin
    fi
    if [ ! -e "/bin/$locker" ]
    then
        sudo cp utils/$locker /bin
    fi
    if [ ! -e "$HOME/src/i3-gnome" ]
    then
        mkdir -p "$HOME/src/i3-gnome"
        git clone https://github.com/i3-gnome/i3-gnome.git "$HOME/src/i3-gnome"
    fi
    cd "$HOME/src/i3-gnome"
    sudo make install
    cd $old_dir
}

setup_vim() {
    local vim_dir="$HOME/.vim"
    if [ -d "$vim_dir" ]
    then
        rm -rf $vim_dir
    fi

    git clone https://github.com/VundleVim/Vundle.vim.git $vim_dir/bundle/Vundle.vim
    git clone https://github.com/Valloric/YouCompleteMe.git $vim_dir/bundle/YouCompleteMe
    cd $vim_dir/bundle/YouCompleteMe && git submodule update --init --recursive
    ./install.py --clang-completer
    cd -
}

setup_neovim() {
    sudo apt install fzf ripgrep fd-find -y
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt update && sudo apt install neovim -y
    
    if [ ! -e ~/.config/nvim ]
    then
        mkdir -p ~/.config/nvim
        git clone https://github.com/eco32i/kickstart.nvim.git ~/.config/nvim
    fi
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    source ~/.bashrc
    nvm install npm
    nvim --headless "+Lazy! sync" +qa
}
    

show_help() {
    cat <<EOF
    usage: $0 options

    Bootstraps a new Ubuntu install to setup most common dev dependencies and bioinformatics software,
    python stack, google browser, vim and a number of plugins, i3 windows manager and a custom GNOME theme based on Arc-Dark.

    OPTIONS:

    -h | --help     display this help text and exit
    -c | --core     upgrade GNOME to latest version, install dev dependencies,
                    install bioinformatics a nd data analysis packages
    -g | --google   install google chrome (beta channel) and google talk plugin
    -i | --i3       set up i3 windows manager and compton compositor
    -v | --vim      setup vim plugin management (Vundle) and YouCompleteMe
                    autocompleter
    -n | --nvim     setup neovim
    -a | --all      all of the above
EOF
}

readonly OPTS=`getopt -o acgihvn --long all,core,google,i3,help,vim,nvim  -n 'bootstrap.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Failed to parse options." >&2; exit 1; fi
eval set -- "$OPTS"

while true
do
    case "$1" in
        -a|--all)
            install_core
            install_google
            setup_i3
            setup_vim
            setup_neovim
            shift
            ;;
        -c|--core)
            install_core
            shift
            ;;
        -g|--google)
            install_google
            shift
            ;;
        -i|--i3)
            setup_i3
            shift
            ;;
        -h|--help)
            show_help
            shift
            ;;
        -v|--vim)
            setup_vim
            shift
            ;;
        -n|--nvim)
            setup_neovim
            shift
            ;;
        * )
            break
            ;;
    esac
done

